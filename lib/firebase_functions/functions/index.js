const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// HTTP function to delete a user by UID
exports.deleteUser = onRequest(async (req, res) => {
  // Verify the request method
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const uid = req.body.uid; // Expecting 'uid' in the POST request body

  if (!uid) {
    res.status(400).send("Bad Request: UID is required.");
    return;
  }

  try {
    await admin.auth().deleteUser(uid);
    res.status(200).send(`Successfully deleted user with UID: ${uid}`);
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).send(`Error deleting user: ${error.message}`);
  }
});
