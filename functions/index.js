// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated, onDocumentDeleted} = require("firebase-functions/v2/firestore");
const functions = require('firebase-functions/v1');

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

exports.blockUser = onDocumentCreated("/users/{currentUid}/blocked-users/{blockedUserId}", async (event) => {
    const { currentUid, blockedUserId } = event.params;
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

exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
    const uid = user.uid;
    const db = getFirestore();

    try {
        const followerSnapshot = await db.collection("users").doc(uid).collection("user-followers").get();

        followerSnapshot.forEach((doc) => {
            logger.log("Follower id ", doc.id);
            db.collection('users').doc(doc.id).collection('user-following').doc(uid).delete();
        });

        const followingSnapshot = await db.collection('users').doc(uid).collection('user-following').get();
        followingSnapshot.forEach((doc) => {
            db.collection('users').doc(doc.id).collection('user-following').doc(uid).delete();
        });

        const followingCollection = db.collection("users").doc(uid).collection("user-following");
        await deleteCollection(db, followingCollection, 100); 

        const userPostsSnapshot = await db.collection('posts').where('authorID', '==', uid).get();

        userPostsSnapshot.forEach((doc) => {
            logger.log("Post id ", doc.id);
            db.collection('posts').doc(doc.id).delete();
        });

        const threadsSnapshot = await db.collection("threads").where('uids', 'array-contains-any', [uid]).get();

        const deletePromises = threadsSnapshot.docs.map(async (doc) => {
            logger.log("Thread id ", doc.id);
            const threadsCollection = db.collection("threads").doc(doc.id).collection("messages");
            await deleteCollection(db, threadsCollection, 100);
        });
        await Promise.all(deletePromises);

        const collectionsToDelete = [
            "user-feed",
            "user-likes",
            "blocked-users",
            "saved-posts",
            "user-notifications"
        ];

        await Promise.all(collectionsToDelete.map(async (collection) => {
            const ref = db.collection("users").doc(uid).collection(collection);
            await deleteCollection(db, ref, 100);
        }));

        await db.collection('users').doc(uid).delete();        

        return null;
    } catch (err) {
        logger.log(err);
    }
});

exports.sendPushNotification = onDocumentCreated('/users/{currentUid}/user-notifications/{notificationId}', async (event) => {
    const currentUid = event.params.currentUid;
    const snapshot = event.data;
    const data = snapshot.data();
    const type = data.type;
    const senderUid = data.senderID;
    const db = getFirestore();

    var notificationMessage = ""

    logger.log("Notification sender uid ", senderUid);
    logger.log("Notification type ", type);

    try {
        const currentUserSnapshot = await db.collection("users").doc(currentUid).get();
        const userData = currentUserSnapshot.data();
        const fcmToken = userData.fcmToken;

        logger.log("FCM Token: ", fcmToken);

        if (type === 0) {
            notificationMessage = ' liked one of your posts.'
        } else if (type === 1) {
            notificationMessage = ' replied to one of your posts.'
        } else if (type === 2) {
            notificationMessage = ' reposted one of your posts.'
        } else if (type === 3) {
            notificationMessage = ' started following you.'
        }

        const senderSnapshot = await db.collection("users").doc(senderUid).get();
        const senderData = senderSnapshot.data();
        const senderUsername = senderData.username;

        logger.log("Sender username: ", senderUsername);

        const message = {
            notification: { title: 'Instagram ProPlus', body: senderUsername + notificationMessage }, 
            token: fcmToken
        };

        admin.messaging().send(message).then((response) => {
            logger.log('Successfully sent message:', response);
        })
        .catch((error) => {
            logger.log('Error sending message:', error);
        });
        
        return null;
    } catch (err) {
        logger.log(err);
    }
});


async function deleteCollection(db, collectionPath, batchSize) {
    const query = collectionPath.limit(batchSize);
  
    return new Promise((resolve, reject) => {
      deleteQueryBatch(db, query, resolve).catch(reject);
    });
  };
  
async function deleteQueryBatch(db, query, resolve) {
    const snapshot = await query.get();
    
    const batchSize = snapshot.size;
    if (batchSize === 0) {
        logger.log("Snapshot size is 0");
      // When there are no documents left, we are done
      resolve();
      return;
    }
  
    // Delete documents in a batch
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      logger.log("Snapshot doc ", doc.id);
      batch.delete(doc.ref);
    });
    await batch.commit();
  
    // Recurse on the next process tick, to avoid
    // exploding the stack.
    process.nextTick(() => {
      deleteQueryBatch(db, query, resolve);
    });
};