//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
type Firestore = admin.firestore.Firestore
const app = admin.initializeApp();

export const computeAverageReview = functions.firestore
  .document('reviews/{reviewId}').onWrite((change, context) => {
    // get the data from the write event
    const eventData = change.after.data();
    // get the previous value, if it exists
    const prev = change.before;
    const rating = eventData.rating;
    let previousValue
    if (prev.exists) {
        previousValue = prev.data();
        const prevRating = previousValue.rating;
        if (rating === prevRating) {
            console.log("not a new rating.");
            return null;
        }
    }
    // get the restaurant ID
    const restaurantID = eventData.restaurantID;
    // get a reference to the root of the firestore DB
    const db = app.firestore();
    // if a previous value exists, then it needs to be replaced
    // when computing an average. Otherwise, add the new rating
    if (prev.exists) {
        const difference = previousValue.rating - rating;
        return updateAverage(db, restaurantID, difference, true);
    } else {
        return updateAverage(db, restaurantID, rating, false);
    }
  });

  export const updateRest = functions.firestore.document('restaurants/{restaurantID}').onUpdate((change, context) => {
    const eventData = change.after.data();
    const restaurantID = context.params.restaurantID;
    const prevEventData = change.before.data();
    const name = eventData.name;
    const oldName = prevEventData.name;
    if (oldName === name) {
        console.log("change was not in name. No need to update reviews.");
        return null;
    }
    const db = app.firestore();
    // if name was updated
    return updateRestaurant(db, restaurantID, name);
});

  async function updateAverage(db: Firestore, restaurantID: string, newRating: number, prev: boolean) {
    const updateDB = db.collection('restaurants').doc(restaurantID);
    const transactionResult = await db.runTransaction(t => {
        return (async () => {
            const restaurantDoc = await t.get(updateDB);
            if (!restaurantDoc.exists) {
                console.log("Document does not exist!");
                return null;
            }
            const oldRating = restaurantDoc.data().averageRating;
            const oldNumReviews = restaurantDoc.data().reviewCount;
            let newNumReviews = oldNumReviews+1;
            let newAvgRating = ((oldRating*oldNumReviews)+newRating)/newNumReviews;
            // no need to increase review numbers if not a new review
            // subtract the different made by the review
            if (prev) {
                newNumReviews = oldNumReviews;
                newAvgRating = ((oldRating*oldNumReviews)-newRating)/oldNumReviews;
            }
            await t.update(updateDB, { averageRating: newAvgRating, reviewCount: newNumReviews });
            console.log("average updated");
            return null;
        })();
    })
   return transactionResult;
  }

// update changes to restaurant
async function updateRestaurant(db: Firestore, restaurantID: string, name: string) {
    const updateRef = db.collection('reviews');
    // query a list of reviews of the restaurant
    const queryRef = updateRef.where('restaurantID', '==', restaurantID);
    const batch = db.batch();
    const reviewsSnapshot = await queryRef.get();
    for (const doc of reviewsSnapshot.docs) {
        await batch.update(doc.ref, {restaurantName: name});
    };
    await batch.commit();
    console.log(`name of restaurant updated to ${name}`);
}

export const watchForYums = functions.firestore.document('pendingYums/{pendingYumID}').onCreate((snapshot, context) => {
    // get the data from the write event
    const eventData = snapshot.data();
    const reviewID = eventData.review;
    const userID = eventData.userId;
    const userName = eventData.userName;
    const db = app.firestore();
    const pendingYumID = context.params.pendingYumID;
    console.log(`Found a pending yum for review ${reviewID} by ${userName} (Id: ${userID}`);
    return addYum(db, reviewID, userID, userName, pendingYumID);
});

async function addYum(db: Firestore, reviewID: string, userId: string, userName: string, docID: string) {
    // First, we need to figure out if there's already a yum by this user
    const transactionResult = await db.runTransaction(t => {
        const pendingYum = db.collection('pendingYums').doc(docID)
        const targetReview = db.collection('reviews').doc(reviewID);
        const thisUsersYum =  targetReview.collection('yums').doc(userId);
        return (async () => {
            const existingYumDoc = await t.get(thisUsersYum);
            const targetReviewDoc = await t.get(targetReview);
            let shouldUpdateReview = true;
            if (existingYumDoc.exists) {
                console.log("User has already yummed this review. We won't update it.");
                shouldUpdateReview = false;
            }
            if (!targetReviewDoc.exists) {
                // This should never happen (famous last words)
                console.error("Target reivew doc doesn't exist?!");
                shouldUpdateReview = false;
            }
            if (shouldUpdateReview) {
                // We're going to increment the yumCount
                const oldYumCount = targetReviewDoc.data().yumCount;
                const newYumcount = oldYumCount + 1
                await t.update(targetReview, {yumCount: newYumcount})
                console.log("Review yumCount has been updated to " + newYumcount)

                // And add the new yum document to indicate that this user has already yummed the review
                const newYumData = {username: userName};
                await t.set(thisUsersYum, newYumData);   
                console.log("New yum document has been added");             
            }
            // No matter what happens, we'll want to delete the pending yum
            await t.delete(pendingYum);
            console.log("Pending yum removed");
            return null;
        })();
    });
    return transactionResult;
}
