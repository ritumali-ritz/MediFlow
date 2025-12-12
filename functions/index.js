
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 1. Audit Log Trigger
// Listens for any change in 'tokens' and logs it to 'audit_logs'
exports.auditTokenChanges = functions.firestore
  .document("tokens/{tokenId}")
  .onWrite(async (change, context) => {
    const tokenId = context.params.tokenId;
    const previousData = change.before.exists ? change.before.data() : null;
    const newData = change.after.exists ? change.after.data() : null;

    if (!newData) return; // Deleted

    const statusChanged = previousData && previousData.status !== newData.status;
    
    if (statusChanged || !previousData) {
      await admin.firestore().collection("audit_logs").add({
        tokenId: tokenId,
        oldStatus: previousData ? previousData.status : "new",
        newStatus: newData.status,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: "system" // Ideally, pass userId in the update
      });
      
      // 2. Notification Dispatcher
      // If status becomes 'serving', notify patient
      if (newData.status === 'serving') {
         const patientId = newData.patientId;
         const userDoc = await admin.firestore().collection("users").doc(patientId).get();
         const fcmToken = userDoc.data().fcmToken;
         
         if (fcmToken) {
           await admin.messaging().send({
             token: fcmToken,
             notification: {
               title: "It's your turn!",
               body: `Token #${newData.tokenNumber} is now being served. Please proceed to the room.`,
             },
             data: {
               screen: "token_view",
               tokenId: tokenId
             }
           });
         }
      }
    }
  });

// 3. Priority Approval (Callable Function)
// Clinic staff calls this to approve a fast-track request
exports.approvePriority = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
  
  // Verify requester is doctor/admin (implementation pending custom claims)
  // Logic: Upgrade token status or re-order queue
  
  const { tokenId } = data;
  
  await admin.firestore().collection("tokens").doc(tokenId).update({
    isPriority: true,
    estimatedTime: admin.firestore.FieldValue.serverTimestamp() // Bump to now
  });
  
  return { success: true };
});
