import * as functions from 'firebase-functions';

exports.computeAverageReview = functions.firestore
  .document('reviews/{reviewId}').onWrite((event) => {
    // get the data from the write event
    const eventData = event.data.data();
    const restaurantID = eventData.restaurantID;
    const rating = eventData.rating;
    const db = event.data.ref.firestore;
    
    // get the previouw value, if it exists
    const prev = event.data.previous
    const previousValue = event.data.previous.data();
    if (prev.exists) {
        const difference = previousValue.rating - rating
        return updateAverage(db, restaurantID, difference, true);
    } else {
        return updateAverage(db, restaurantID, rating, false);
    }
  });

  async function updateAverage(db, restaurantID, newRating, prev) {
    const updateDB = db.collection('restaurants').doc(restaurantID);
    const transactionResult = await db.runTransaction(t => {
        return (async () => {
            const restaurantDoc = await t.get(updateDB);
            if (!restaurantDoc.exists) {
                console.log("Document does not exist!");
            }
            const oldRating = restaurantDoc.data().averageRating;
            const oldNumReviews = restaurantDoc.data().reviewCount;
            let newNumReviews = oldNumReviews+1;
            let newAvgRating = ((oldRating*oldNumReviews)+newRating)/newNumReviews;
            // no need to increase review numbers if not a new review
            // subtract the different made by the review
            if (prev === true) {
                newNumReviews = oldNumReviews
                newAvgRating = ((oldRating*oldNumReviews)-newRating)/oldNumReviews
            }
            const updateRating = await t.update(updateDB, { averageRating: newAvgRating, reviewCount: newNumReviews });
            return updateRating;
        })();
    })
   return transactionResult;
  }
