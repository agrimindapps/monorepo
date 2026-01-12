# Admin Setup Guide - Livestock Catalog

This guide shows how to configure Firebase Auth custom claims to mark a user as admin for the livestock catalog management feature.

## Overview

The admin-in-app architecture requires Firebase Auth custom claims to differentiate between:
- **Admin users**: Full CRUD access to livestock catalog + publish capability
- **Regular users**: Read-only access, synced from Firebase Storage

## Prerequisites

- Firebase project configured and linked to your Flutter app
- Firebase CLI installed: `npm install -g firebase-tools`
- User account already created in Firebase Auth (get the UID from Firebase Console)

---

## Option 1: Firebase CLI (Quickest Method)

### Steps:

1. **Login to Firebase CLI**
   ```bash
   firebase login
   ```

2. **Set custom claim for admin user**
   ```bash
   firebase auth:export users.json --project YOUR_PROJECT_ID
   # Find your user's UID in users.json, then:
   
   firebase functions:config:set admin.email="your-admin-email@example.com" --project YOUR_PROJECT_ID
   ```

3. **Use Firebase Admin SDK via Node.js script** (recommended for CLI)
   
   Create `set-admin.js`:
   ```javascript
   const admin = require('firebase-admin');
   const serviceAccount = require('./serviceAccountKey.json');
   
   admin.initializeApp({
     credential: admin.credential.cert(serviceAccount)
   });
   
   const uid = 'YOUR_USER_UID'; // Get from Firebase Console → Authentication
   
   admin.auth().setCustomUserClaims(uid, { admin: true })
     .then(() => {
       console.log(`✅ Admin claim set for user ${uid}`);
       console.log('⚠️  User must logout and login again for changes to take effect');
       process.exit(0);
     })
     .catch((error) => {
       console.error('❌ Error setting custom claim:', error);
       process.exit(1);
     });
   ```

4. **Download service account key**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` (keep secure, don't commit!)

5. **Install dependencies and run**
   ```bash
   npm install firebase-admin
   node set-admin.js
   ```

6. **Force logout/login in app**
   - User must sign out and sign back in for token to refresh
   - Or call `await FirebaseAuth.instance.currentUser?.getIdToken(true);`

---

## Option 2: Cloud Function (Recommended for Production)

This method automatically sets admin claim on user creation based on a hardcoded email.

### Steps:

1. **Initialize Firebase Functions** (if not already done)
   ```bash
   cd apps/app-agrihurbi
   firebase init functions
   ```

2. **Create Cloud Function**
   
   Edit `functions/index.js`:
   ```javascript
   const functions = require('firebase-functions');
   const admin = require('firebase-admin');
   admin.initializeApp();
   
   // 🔧 Configure admin email here
   const ADMIN_EMAIL = 'your-admin-email@example.com';
   
   exports.setAdminClaim = functions.auth.user().onCreate(async (user) => {
     if (user.email === ADMIN_EMAIL) {
       try {
         await admin.auth().setCustomUserClaims(user.uid, { admin: true });
         console.log(`✅ Admin claim set for ${user.email}`);
       } catch (error) {
         console.error('❌ Error setting admin claim:', error);
       }
     }
   });
   
   // Manual trigger function (call via HTTP if user already exists)
   exports.makeAdmin = functions.https.onCall(async (data, context) => {
     // Only allow existing admins to create new admins
     if (context.auth?.token?.admin !== true) {
       throw new functions.https.HttpsError('permission-denied', 'Only admins can make other users admin');
     }
     
     const { email } = data;
     try {
       const user = await admin.auth().getUserByEmail(email);
       await admin.auth().setCustomUserClaims(user.uid, { admin: true });
       return { success: true, message: `Admin claim set for ${email}` };
     } catch (error) {
       throw new functions.https.HttpsError('internal', error.message);
     }
   });
   ```

3. **Deploy Cloud Function**
   ```bash
   firebase deploy --only functions
   ```

4. **For existing users** - Use the manual trigger function from Flutter:
   ```dart
   final callable = FirebaseFunctions.instance.httpsCallable('makeAdmin');
   try {
     final result = await callable.call({'email': 'user@example.com'});
     print(result.data['message']);
   } catch (e) {
     print('Error: $e');
   }
   ```

5. **User must logout/login** for token to refresh

---

## Option 3: Firebase Console + REST API

### Steps:

1. **Get user UID from Firebase Console**
   - Go to Firebase Console → Authentication → Users
   - Copy the UID of the user you want to make admin

2. **Use Firebase Admin REST API**
   
   Create `set-admin.sh`:
   ```bash
   #!/bin/bash
   
   USER_UID="YOUR_USER_UID"
   PROJECT_ID="YOUR_PROJECT_ID"
   SERVICE_ACCOUNT_KEY="serviceAccountKey.json"
   
   # Get access token
   ACCESS_TOKEN=$(cat $SERVICE_ACCOUNT_KEY | jq -r .private_key | \
     openssl dgst -sha256 -sign /dev/stdin | \
     base64)
   
   # Set custom claim
   curl -X PATCH \
     "https://identitytoolkit.googleapis.com/v1/accounts:update?key=YOUR_API_KEY" \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{
       \"localId\": \"$USER_UID\",
       \"customAttributes\": \"{\\\"admin\\\":true}\"
     }"
   ```

---

## Verification

After setting the admin claim, verify it worked:

### Method 1: Firebase Console
1. Go to Firebase Console → Authentication → Users
2. Click on the user
3. Scroll down to "Custom claims"
4. Should show: `{"admin": true}`

### Method 2: Flutter App
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final idTokenResult = await user.getIdTokenResult(true); // Force refresh
  final isAdmin = idTokenResult.claims?['admin'] == true;
  print('Is admin: $isAdmin');
}
```

### Method 3: UserRoleService (in app)
```dart
final userRoleService = ref.read(userRoleServiceProvider);
final role = await userRoleService.getUserRole();
print('User role: $role'); // Should print: UserRole.admin
```

---

## Important Notes

### Token Refresh
- Custom claims are NOT immediately available to the app
- User must either:
  - **Logout and login again** (recommended)
  - **Force token refresh**: `await user.getIdToken(true);`
  - **Wait 1 hour** for automatic token refresh

### Security Rules
After setting admin claim, update Firebase Storage rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /livestock/{file} {
      // Anyone authenticated can read
      allow read: if request.auth != null;
      
      // Only admins can write
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

### Firestore Rules (if used)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /livestock/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

---

## Troubleshooting

### "Admin claim not working"
- ✅ User logged out and back in?
- ✅ Token refreshed with `getIdToken(true)`?
- ✅ Check Firebase Console → User → Custom Claims
- ✅ Check `idTokenResult.claims` in Flutter debugger

### "Permission denied when publishing"
- ✅ Firebase Storage rules updated?
- ✅ Admin claim actually set (check Firebase Console)?
- ✅ User logged in with the correct account?

### "Cloud Function not triggering"
- ✅ Function deployed successfully?
- ✅ Check Firebase Console → Functions → Logs
- ✅ Email matches exactly (case-sensitive)?

---

## Next Steps

After setting up admin user:

1. ✅ **Override SharedPreferences in main.dart** (see IMPLEMENTATION_COMPLETE.md)
2. ✅ **Add admin route guards** (restrict /admin routes to admins only)
3. ✅ **Integrate PublishCatalogButton** into UI
4. ✅ **Test complete flow** (admin publish → user sync)

---

## Quick Reference

| Method | Setup Time | Complexity | Production Ready |
|--------|-----------|------------|------------------|
| Firebase CLI + Node.js | 5 min | Low | ⚠️ Manual |
| Cloud Function | 15 min | Medium | ✅ Automatic |
| REST API | 10 min | Medium | ⚠️ Manual |

**Recommendation**: Use Cloud Function for automatic setup, or Node.js script for quick one-time setup.
