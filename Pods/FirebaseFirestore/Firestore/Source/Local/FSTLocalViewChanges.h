/*
 * Copyright 2017 Google
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

#import <Foundation/Foundation.h>

#include "Firestore/core/src/firebase/firestore/core/view_snapshot.h"
#include "Firestore/core/src/firebase/firestore/model/document_key_set.h"
#include "Firestore/core/src/firebase/firestore/model/types.h"

@class FSTMutation;
@class FSTQuery;

namespace core = firebase::firestore::core;
namespace model = firebase::firestore::model;

NS_ASSUME_NONNULL_BEGIN

/**
 * A set of changes to what documents are currently in view and out of view for a given query.
 * These changes are sent to the LocalStore by the View (via the SyncEngine) and are used to pin /
 * unpin documents as appropriate.
 */
@interface FSTLocalViewChanges : NSObject

+ (instancetype)changesForTarget:(model::TargetId)targetID
                       addedKeys:(model::DocumentKeySet)addedKeys
                     removedKeys:(model::DocumentKeySet)removedKeys;

+ (instancetype)changesForViewSnapshot:(const core::ViewSnapshot &)viewSnapshot
                          withTargetID:(model::TargetId)targetID;

- (id)init NS_UNAVAILABLE;

@property(readonly) model::TargetId targetID;

- (const model::DocumentKeySet &)addedKeys;
- (const model::DocumentKeySet &)removedKeys;

@end

NS_ASSUME_NONNULL_END
