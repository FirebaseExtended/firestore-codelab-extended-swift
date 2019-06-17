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

#import "FIRFirestore.h"

#include <memory>
#include <string>

#include "Firestore/core/src/firebase/firestore/api/firestore.h"
#include "Firestore/core/src/firebase/firestore/auth/credentials_provider.h"
#include "Firestore/core/src/firebase/firestore/util/async_queue.h"

@class FIRApp;
@class FSTFirestoreClient;
@class FSTUserDataConverter;

namespace api = firebase::firestore::api;
namespace auth = firebase::firestore::auth;
namespace model = firebase::firestore::model;
namespace util = firebase::firestore::util;

NS_ASSUME_NONNULL_BEGIN

@interface FIRFirestore (/* Init */)

/**
 * Initializes a Firestore object with all the required parameters directly. This exists so that
 * tests can create FIRFirestore objects without needing FIRApp.
 */
- (instancetype)initWithDatabaseID:(model::DatabaseId)databaseID
                    persistenceKey:(std::string)persistenceKey
               credentialsProvider:(std::unique_ptr<auth::CredentialsProvider>)credentialsProvider
                       workerQueue:(std::shared_ptr<util::AsyncQueue>)workerQueue
                       firebaseApp:(FIRApp *)app;
@end

/** Internal FIRFirestore API we don't want exposed in our public header files. */
@interface FIRFirestore (Internal)

/** Checks to see if logging is is globally enabled for the Firestore client. */
+ (BOOL)isLoggingEnabled;

+ (FIRFirestore *)recoverFromFirestore:(std::shared_ptr<api::Firestore>)firestore;

/**
 * Shutdown this `FIRFirestore`, releasing all resources (abandoning any outstanding writes,
 * removing all listens, closing all network connections, etc.).
 *
 * @param completion A block to execute once everything has shut down.
 */
- (void)shutdownWithCompletion:(nullable void (^)(NSError *_Nullable error))completion
    NS_SWIFT_NAME(shutdown(completion:));

/**
 * Clears the persistent storage. This includes pending writes and cached documents.
 *
 * Must be called while the firestore instance is not started (after the app is shutdown or when
 * the app is first initialized). On startup, this method must be called before other methods
 * (other than `FIRFirestore.settings`). If the firestore instance is still running, the function
 * will complete with an error code of `FailedPrecondition`.
 *
 * Note: `clearPersistence(completion:)` is primarily intended to help write reliable tests that
 * use Firestore. It uses the most efficient mechanism possible for dropping existing data but
 * does not attempt to securely overwrite or otherwise make cached data unrecoverable. For
 * applications that are sensitive to the disclosure of cache data in between user sessions we
 * strongly recommend not to enable persistence in the first place.
 */
- (void)clearPersistenceWithCompletion:(nullable void (^)(NSError *_Nullable error))completion;

- (const std::shared_ptr<util::AsyncQueue> &)workerQueue;

@property(nonatomic, assign, readonly) std::shared_ptr<api::Firestore> wrapped;

@property(nonatomic, assign, readonly) const model::DatabaseId &databaseID;
@property(nonatomic, strong, readonly) FSTUserDataConverter *dataConverter;

@end

NS_ASSUME_NONNULL_END
