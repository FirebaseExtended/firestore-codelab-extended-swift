import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
type Firestore = admin.firestore.Firestore

export const computeAverageReview = functions.firestore
  .document('reviews/{reviewId}').onWrite((event) => {
    // get the data from the write event
    const eventData = event.data.data();
    // get the previous value, if it exists
    const prev = event.data.previous;
    const previousValue = prev.data();
    const rating = eventData.rating;
    const prevRating = previousValue.rating;
    if (rating === prevRating) {
        console.log("not a new rating.");
        return null;
    }
    // get the restaurant ID
    const restaurantID = eventData.restaurantID;
    // get a reference to the root of the firestore DB
    const db = event.data.ref.firestore;
    
    // if a previous value exists, then it needs to be replaced
    // when computing an average. Otherwise, add the new rating
    if (prev.exists) {
        const difference = previousValue.rating - rating
        return updateAverage(db, restaurantID, difference, true);
    } else {
        return updateAverage(db, restaurantID, rating, false);
    }
  });

  export const updateRest = functions.firestore.document('restaurants/{restaurantID}').onUpdate((event) => {
    const db = event.data.ref.firestore;
    const restaurantID = event.params.restaurantID;
    const eventData = event.data.data();
    const prevEventData = event.data.previous.data();
    const name = eventData.name;
    const oldName = prevEventData.name;
    if (oldName === name) {
        console.log("change was not in name. No need to update reviews.");
        return null;
    }
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
        await batch.update(doc.ref, {name: name});
    };
    await batch.commit();
    console.log(`name of restaurant updated to ${name}`);
}
