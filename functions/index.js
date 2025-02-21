// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated, onDocumentDeleted} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const { user } = require("firebase-functions/v1/auth");

initializeApp();

exports.blockUser = onDocumentCreated("/users/{currentUid}/blocked-users/{blockedUserId}", async (event) => {
    const currentUid = event.params.currentUid; 
    const blockedUserId = event.params.blockedUserId; 
    const db = getFirestore();

    try {
        const threadsSnapshot = await db.collection("threads").where('uids', 'array-contains-any', [currentUid]).get();

        threadsSnapshot.forEach(async (doc) => {
            const threadData = doc.data();
            logger.log("Thread data is ", threadData);

            if (threadData.uids.includes(blockedUserId)) {
                const threadsCollection = db.collection("threads").doc(doc.id).collection("messages");
                await deleteCollection(db, threadsCollection, 100); 

                db.collection("threads").doc(doc.id).delete();
            }
        });

        const notificationsSnapshot = await db.collection("notifications").doc(currentUid).collection("user-notifications").where('notificationSenderUid', '==', blockedUserId).get();

        notificationsSnapshot.forEach((doc) => {
            db.collection('notifications').doc(currentUid).collection('user-notifications').doc(doc.id).delete();
        });

        return null;
    } catch (err) {
        logger.log(err);
    }
});

exports.updateUserFeedAfterFollow = onDocumentCreated("/users/{currentUid}/user-following/{followedUid}", async (event) => {
    const currentUid = event.params.currentUid;
    const followedUid = event.params.followedUid;
    const db = getFirestore();

    try {
        const snapshot = await db.collection('posts').where('authorID', '==', followedUid).get();
        const batch = db.batch();

        snapshot.forEach((doc) => {
            const postId = doc.id;
            const postData = doc.data();
            const authorID = postData.authorID;
            const timestamp = postData.timestamp;

            const data = {
                authorID, 
                timestamp
            }

            const userFeedRef = db.collection('users').doc(currentUid).collection('user-feed').doc(postId);
            batch.set(userFeedRef, data);
        });

        await batch.commit(); 
        return null;
    } catch (err) {
        logger.error("Error updating feed after follow", err);
        throw err;
    }
});

exports.updateUserFeedAfterUnfollow = onDocumentDeleted("/users/{currentUid}/user-following/{unfollowedUid}", async (event) => {
    const currentUid = event.params.currentUid;
    const unfollowedUid = event.params.unfollowedUid;
    const db = getFirestore();

    try {
        const snapshot = await db.collection('posts').where('authorID', '==', unfollowedUid).get();
        const batch = db.batch();

        snapshot.forEach((doc) => {
            const postId = doc.id;
            const userFeedRef = db.collection('users').doc(currentUid).collection('user-feed').doc(postId);
            batch.delete(userFeedRef);
        });

        await batch.commit();
    } catch (err) {
        logger.error("Error updating feed after unfollow", err);
        throw err;
    }
});

exports.updateUserFeedAfterPost = onDocumentCreated("/posts/{postId}", async (event) => {
    const postId = event.params.postId; 
    const snapshot = event.data; 
    const data = snapshot.data();
    const authorID = data.authorID;
    const timestamp = data.timestamp;
    const db = getFirestore();

    try {
        const followerSnapshot = await db.collection('users').doc(authorID).collection('user-followers').get();
        const batch = db.batch();

        const data = {
            authorID, 
            timestamp
        }

        followerSnapshot.forEach((doc) => {
            const userFeedRef = db.collection('users').doc(doc.id).collection('user-feed').doc(postId);
            batch.set(userFeedRef, data);
        });

        const ownerFeedRef = db.collection('users').doc(authorID).collection('user-feed').doc(postId);
        batch.set(ownerFeedRef, data);

        await batch.commit();
        logger.log("User feeds updated after post creation.");
    } catch {
        logger.error("Error updating feed after post", err);
        throw err;
    }
});

exports.updateFeedsAfterPostDelete = onDocumentDeleted("/posts/{postId}", async (event) => {
    const postId = event.params.postId; 
    const snapshot = event.data; 
    const data = snapshot.data();
    const authorID = data.authorID;
    const db = getFirestore();

    try {
        const followerSnapshot = await db.collection('users').doc(authorID).collection('user-followers').get();
        const batch = db.batch();

        followerSnapshot.forEach((doc) => {
            const userFeedRef = db.collection('users').doc(doc.id).collection('user-feed').doc(postId);
            batch.delete(userFeedRef);
        });

        const ownerFeedRef = db.collection('users').doc(authorID).collection('user-feed').doc(postId);
        batch.delete(ownerFeedRef);

        await batch.commit();
        logger.log("User feeds updated after post creation.");
    } catch {
        logger.error("Error updating feed after post", err);
        throw err;
    }
});