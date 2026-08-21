# NearoMart Backend: Railway Deployment Report

This report provides a comprehensive analysis of the `Backend/` codebase for deployment to Railway, covering environment variables, database configuration, authentication, and media storage.

## 1. Complete Environment Variable List

| Variable | Required? | Used In | Purpose | Railway Required? | Value Source |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `PORT` | Optional | `index.js` | Port the server listens on (defaults to 5000) | **Yes** | Automatically provided by Railway |
| `MONGODB_URI` | **Required** | `index.js`, `clear_db.js` | MongoDB connection string | **Yes** | MongoDB Atlas Connection String |
| `JWT_SECRET` | **Required** | `authService.js`, `authMiddleware.js`, `socketService.js` | Signing and verifying JWT tokens | **Yes** | Long random string (secure) |
| `MEDIA_STORAGE` | Optional | `uploadController.js` | Switches between 'gridfs' and 's3' | No | Set to `gridfs` or leave blank for default |
| `AWS_REGION` | Optional* | `uploadController.js` | AWS Region for S3 storage | No | Only if `MEDIA_STORAGE=s3` |
| `AWS_ACCESS_KEY` | Optional* | `uploadController.js` | AWS Access Key for S3 storage | No | Only if `MEDIA_STORAGE=s3` |
| `AWS_SECRET_KEY` | Optional* | `uploadController.js` | AWS Secret Key for S3 storage | No | Only if `MEDIA_STORAGE=s3` |
| `S3_BUCKET_NAME` | Optional* | `uploadController.js` | AWS S3 Bucket Name | No | Only if `MEDIA_STORAGE=s3` |
| `GOOGLE_APPLICATION_CREDENTIALS` | **Required** | `firebase-config.js` | Firebase Admin SDK authentication | **Yes** | Path to Firebase service account JSON |

---

## 2. MongoDB

*   **Variable Name:** `MONGODB_URI`
*   **Localhost Fallback:** There is **no localhost fallback** in the actual `index.js` code. It directly uses `process.env.MONGODB_URI`.
*   **Production Requirement:** The application **requires MongoDB Atlas** (or a remote instance) for production.
*   **GridFS Usage:** **Yes**, GridFS is used for media uploads. The `uploadController.js` specifically uses `mongoose.mongo.GridFSBucket` with a bucket name of `media`.
*   **Additional Variables:** None. All GridFS operations use the primary `MONGODB_URI` connection.

> [!IMPORTANT]
> **SECRET STATUS:** A sensitive `MONGODB_URI` was detected in the local environment. **DO NOT** commit your local `.env` to version control.

---

## 3. JWT

*   **Variable Name:** `JWT_SECRET`
*   **Mandatory:** **Yes**. The application will fail to sign tokens during login and fail to verify them in middleware if this is missing.
*   **Security Implications:** Changing the `JWT_SECRET` in production **will invalidate all existing user sessions**. Users will be forced to log in again.
*   **Production Security:** The secret should be a cryptographically strong string (at least 32-64 characters).

> [!IMPORTANT]
> **SECRET STATUS:** A sensitive `JWT_SECRET` was detected in the local environment. Ensure the production secret is unique and secure.

---

## 4. Firebase Admin

*   **Usage:** **Yes**, it is actively used in `authController.js` to verify `idToken` during the `verifyOtp` process.
*   **Expected Variables/Files:**
    *   It expects `admin.initializeApp()` to find credentials via the **`GOOGLE_APPLICATION_CREDENTIALS`** environment variable.
*   **Service Account Key:** The code in `src/config/firebase-config.js` is not currently configured to read a local file by default (file loading code is commented out).
*   **Railway Compatibility:**
    *   Railway environment variables are strings, but the SDK expects a file path.
    *   **Recommendation:** Set `GOOGLE_APPLICATION_CREDENTIALS` to a path like `/app/service-account.json`. Use a Railway build-step or volume to ensure this file exists with your Firebase JSON content.
*   **Failure Impact:** If credentials are missing, **Login/OTP verification will fail**.

---

## 5. Image / Media Storage

*   **Default Implementation:** **Confirmed as MongoDB GridFS**.
*   **S3 Status:** Optional.
*   **Switch Variable:** `MEDIA_STORAGE`.
    *   If `MEDIA_STORAGE` is **not** set to `s3`, the app defaults to GridFS.
*   **Deployment without S3:** **Yes**, you can deploy safely without any S3/AWS variables.

---

## 6. Railway Configuration

*   **Root Directory:** `Backend/`
*   **Build Command:** `npm install`
*   **Start Command:** `npm start`
*   **PORT Handling:** The app correctly uses `process.env.PORT || 5000`.
*   **Listening Address:** The app correctly listens on `0.0.0.0`.
*   **CORS:** Currently set to allow all origins, which is compatible with Railway.

---

## 7. Final Railway Variable Set

### REQUIRED

| Variable | Source / How to Obtain |
| :--- | :--- |
| **`MONGODB_URI`** | Obtain from MongoDB Atlas (Database > Connect > Drivers). |
| **`JWT_SECRET`** | Generate a long random string. |
| **`GOOGLE_APPLICATION_CREDENTIALS`** | Path to your Firebase service account JSON (e.g., `/app/service-account.json`). |

### OPTIONAL

| Variable | Source / How to Obtain |
| :--- | :--- |
| **`PORT`** | Automatically handled by Railway. |
| **`MEDIA_STORAGE`** | Defaults to `gridfs`. Set explicitly if desired. |

### NOT NEEDED FOR CURRENT SETUP

*   `AWS_REGION`
*   `AWS_ACCESS_KEY`
*   `AWS_SECRET_KEY`
*   `S3_BUCKET_NAME`
