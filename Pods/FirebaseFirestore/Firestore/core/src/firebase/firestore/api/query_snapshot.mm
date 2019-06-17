/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "Firestore/core/src/firebase/firestore/api/query_snapshot.h"

#include <utility>

#import "Firestore/Source/API/FIRDocumentChange+Internal.h"
#import "Firestore/Source/API/FIRDocumentSnapshot+Internal.h"
#import "Firestore/Source/API/FIRFirestore+Internal.h"
#import "Firestore/Source/API/FIRQuery+Internal.h"
#import "Firestore/Source/Core/FSTQuery.h"
#import "Firestore/Source/Model/FSTDocument.h"

#include "Firestore/core/src/firebase/firestore/api/input_validation.h"
#include "Firestore/core/src/firebase/firestore/api/query_core.h"
#include "Firestore/core/src/firebase/firestore/core/view_snapshot.h"
#include "Firestore/core/src/firebase/firestore/model/document_set.h"
#include "Firestore/core/src/firebase/firestore/objc/objc_compatibility.h"
#include "Firestore/core/src/firebase/firestore/util/hard_assert.h"
#include "absl/types/optional.h"

NS_ASSUME_NONNULL_BEGIN

namespace firebase {
namespace firestore {
namespace api {

using api::Firestore;
using core::DocumentViewChange;
using core::ViewSnapshot;
using model::DocumentSet;

QuerySnapshot::QuerySnapshot(std::shared_ptr<Firestore> firestore,
                             FSTQuery* query,
                             core::ViewSnapshot&& snapshot,
                             SnapshotMetadata metadata)
    : firestore_(firestore),
      internal_query_(query),
      snapshot_(std::move(snapshot)),
      metadata_(std::move(metadata)) {
}

Query QuerySnapshot::query() const {
  return Query(internal_query_, firestore_);
}

FSTQuery* QuerySnapshot::internal_query() const {
  return internal_query_;
}

bool operator==(const QuerySnapshot& lhs, const QuerySnapshot& rhs) {
  return lhs.firestore_ == rhs.firestore_ &&
         objc::Equals(lhs.internal_query_, rhs.internal_query_) &&
         lhs.snapshot_ == rhs.snapshot_ && lhs.metadata_ == rhs.metadata_;
}

size_t QuerySnapshot::Hash() const {
  return util::Hash(firestore_.get(), internal_query_, snapshot_, metadata_);
}

void QuerySnapshot::ForEachDocument(
    const std::function<void(DocumentSnapshot)>& callback) const {
  DocumentSet documentSet = snapshot_.documents();
  bool from_cache = metadata_.from_cache();

  for (FSTDocument* document : documentSet) {
    bool has_pending_writes = snapshot_.mutated_keys().contains(document.key);
    DocumentSnapshot snap(firestore_, document.key, document, from_cache,
                          has_pending_writes);
    callback(std::move(snap));
  }
}

static DocumentChange::Type DocumentChangeTypeForChange(
    const DocumentViewChange& change) {
  switch (change.type()) {
    case DocumentViewChange::Type::kAdded:
      return DocumentChange::Type::Added;
    case DocumentViewChange::Type::kModified:
    case DocumentViewChange::Type::kMetadata:
      return DocumentChange::Type::Modified;
    case DocumentViewChange::Type::kRemoved:
      return DocumentChange::Type::Removed;
  }

  HARD_FAIL("Unknown DocumentViewChange::Type: %s", change.type());
}

void QuerySnapshot::ForEachChange(
    bool include_metadata_changes,
    const std::function<void(DocumentChange)>& callback) const {
  if (include_metadata_changes && snapshot_.excludes_metadata_changes()) {
    ThrowInvalidArgument("To include metadata changes with your document "
                         "changes, you must call "
                         "addSnapshotListener(includeMetadataChanges:true).");
  }

  if (snapshot_.old_documents().empty()) {
    // Special case the first snapshot because index calculation is easy and
    // fast. Also all changes on the first snapshot are adds so there are also
    // no metadata-only changes to filter out.
    FSTDocument* last_document = nil;
    size_t index = 0;
    for (const DocumentViewChange& change : snapshot_.document_changes()) {
      FSTDocument* doc = change.document();
      SnapshotMetadata metadata(
          /*pending_writes=*/snapshot_.mutated_keys().contains(doc.key),
          /*from_cache=*/snapshot_.from_cache());
      DocumentSnapshot document(firestore_, doc.key, doc, metadata);

      HARD_ASSERT(change.type() == DocumentViewChange::Type::kAdded,
                  "Invalid event type for first snapshot");
      HARD_ASSERT(!last_document ||
                      util::Ascending(snapshot_.query().comparator.Compare(
                          last_document, change.document())),
                  "Got added events in wrong order");

      callback(DocumentChange(DocumentChange::Type::Added, std::move(document),
                              DocumentChange::npos, index++));
    }

  } else {
    // A DocumentSet that is updated incrementally as changes are applied to use
    // to lookup the index of a document.
    DocumentSet index_tracker = snapshot_.old_documents();
    for (const DocumentViewChange& change : snapshot_.document_changes()) {
      if (!include_metadata_changes &&
          change.type() == DocumentViewChange::Type::kMetadata) {
        continue;
      }

      FSTDocument* doc = change.document();
      SnapshotMetadata metadata(
          /*pending_writes=*/snapshot_.mutated_keys().contains(doc.key),
          /*from_cache=*/snapshot_.from_cache());
      DocumentSnapshot document(firestore_, doc.key, doc, metadata);

      size_t old_index = DocumentChange::npos;
      size_t new_index = DocumentChange::npos;
      if (change.type() != DocumentViewChange::Type::kAdded) {
        old_index = index_tracker.IndexOf(change.document().key);
        HARD_ASSERT(old_index != DocumentSet::npos,
                    "Index for document not found");
        index_tracker = index_tracker.erase(change.document().key);
      }
      if (change.type() != DocumentViewChange::Type::kRemoved) {
        index_tracker = index_tracker.insert(change.document());
        new_index = index_tracker.IndexOf(change.document().key);
      }

      DocumentChange::Type type = DocumentChangeTypeForChange(change);
      callback(DocumentChange(type, std::move(document), old_index, new_index));
    }
  }
}

}  // namespace api
}  // namespace firestore
}  // namespace firebase

NS_ASSUME_NONNULL_END
