# Firebase Admin: Railway-Compatible Implementation Plan

This report outlines the strategy for making the NearoMart Firebase Admin initialization compatible with Railway's environment without committing sensitive service-account JSON files to version control.

## 1. Current State Analysis

*   **File:** `Backend/src/config/firebase-config.js`
*   **Initialization Method:** `admin.initializeApp();`
*   **Requirement:** The default initialization expects the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to a local filesystem path of a service account JSON file.

## 2. Proposed Changes (Code)

To support both local development (file-based) and Railway (environment-based), the following modification is recommended for `Backend/src/config/firebase-config.js`:

```javascript
const admin = require('firebase-admin');

try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    // Railway/Production: Initialize using the JSON string from Environment Variable
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('Firebase Admin initialized via Environment Variable');
  } else {
    // Local: Fallback to default (looks for GOOGLE_APPLICATION_CREDENTIALS file path)
    admin.initializeApp();
    console.log('Firebase Admin initialized via default credentials');
  }
} catch (error) {
  console.error('Firebase Admin initialization failed:', error.message);
}

module.exports = admin;
```

## 3. Deployment Configuration (Railway)

Add the following secret to your Railway Project:

| Variable Name | Value |
| :--- | :--- |
| **`FIREBASE_SERVICE_ACCOUNT`** | The complete content of your `serviceAccountKey.json` as a single string. |

## 4. Verification & Security

*   **[x] Local Compatibility:** Continues to work using existing `GOOGLE_APPLICATION_CREDENTIALS` logic if `FIREBASE_SERVICE_ACCOUNT` is absent.
*   **[x] OTP Verification:** `authController.js` logic remains unchanged as it consumes the initialized `admin` instance.
*   **[x] No Exposure:** Credentials are restricted to the Node.js process and never exposed to Flutter or web clients.
*   **[x] Repository Security:** No private keys or JSON files need to be committed to GitHub.

> [!IMPORTANT]
> **Action Required:** Ensure that `serviceAccountKey.json` is explicitly listed in your `Backend/.gitignore` to prevent accidental commits.
