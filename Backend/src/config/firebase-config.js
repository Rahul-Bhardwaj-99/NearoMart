const admin = require('firebase-admin');

try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    // Railway/Production: Initialize using the JSON string from Environment Variable
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('Firebase Admin initialized successfully via Environment Variable');
  } else {
    // Local: Fallback to default (looks for GOOGLE_APPLICATION_CREDENTIALS file path)
    admin.initializeApp();
    console.log('Firebase Admin initialized successfully via default credentials');
  }
} catch (error) {
  console.warn('Firebase Admin initialization warning:', error.message);
  console.warn('Ensure FIREBASE_SERVICE_ACCOUNT is set in production or GOOGLE_APPLICATION_CREDENTIALS is set locally.');
}

module.exports = admin;
