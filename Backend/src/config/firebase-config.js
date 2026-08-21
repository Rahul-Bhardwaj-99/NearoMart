const admin = require('firebase-admin');

try {
  // If you have a serviceAccountKey.json, you can initialize with:
  // const serviceAccount = require('../../serviceAccountKey.json');
  // admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

  admin.initializeApp();
  console.log('Firebase Admin initialized successfully');
} catch (error) {
  console.warn('Firebase Admin initialization warning:', error.message);
  console.warn('Ensure GOOGLE_APPLICATION_CREDENTIALS is set or you are running on a GCP environment.');
}

module.exports = admin;
