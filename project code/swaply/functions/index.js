const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Runs every minute, checks for sessions starting in ~5 minutes
exports.notifyUpcomingSessions = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async () => {
    const db = admin.firestore();
    const now = new Date();

    // Window: sessions starting between 4 and 6 minutes from now
    const from = new Date(now.getTime() + 4 * 60 * 1000);
    const to   = new Date(now.getTime() + 6 * 60 * 1000);

    const snap = await db.collection("sessions")
      .where("status", "==", "accepted")
      .where("scheduledAt", ">=", from)
      .where("scheduledAt", "<=", to)
      .where("notified", "==", false) // ✅ prevent double-sending
      .get();

    const promises = snap.docs.map(async (doc) => {
      const session = doc.data();

      // Fetch both users' FCM tokens
      const [studentDoc, teacherDoc] = await Promise.all([
        db.collection("users").doc(session.studentId).get(),
        db.collection("users").doc(session.teacherId).get(),
      ]);

      const tokens = [
        studentDoc.data()?.fcmToken,
        teacherDoc.data()?.fcmToken,
      ].filter(Boolean);

      if (tokens.length === 0) return;

      // Send notification to both
      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: "Session Starting Soon 🎯",
          body: `Your ${session.skill} session starts in 5 minutes!`,
        },
        data: {
          sessionId: doc.id, // so app knows which session to open
          type: "session_reminder",
        },
      });

      // Mark as notified so it doesn't send again
      await doc.ref.update({notified: true});
    });

    await Promise.all(promises);
  });