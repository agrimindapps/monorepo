# Admin-in-App Configuration Guide

Complete guide for configuring and deploying the admin-in-app livestock catalog architecture.

## ✅ Implementation Status

### Completed
- ✅ Core architecture (dual-mode repository, UserRole service, Storage datasource)
- ✅ Code generation setup (build_runner, freezed, riverpod_generator)
- ✅ SharedPreferences override in main.dart
- ✅ Admin route with guard (`/admin/livestock`)
- ✅ Admin UI page (AdminLivestockPage with PublishCatalogButton)
- ✅ All 13 generated files created successfully
- ✅ 0 compilation errors (1 non-blocking Freezed warning)

### Remaining Tasks
1. ⏳ Set Firebase Auth custom claim for admin user
2. ⏳ Configure Firebase Storage security rules
3. ⏳ Add admin menu item to UI (optional)
4. ⏳ Test complete workflow

---

## Step 1: Set Admin Custom Claim

Choose one method to mark your user account as admin:

### Option A: Firebase CLI + Node.js Script (Quickest)

1. **Create `set-admin.js` script:**
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
       console.log('⚠️  User must logout and login again');
       process.exit(0);
     })
     .catch((error) => {
       console.error('❌ Error:', error);
       process.exit(1);
     });
   ```

2. **Get service account key:**
   - Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` (DON'T commit!)

3. **Get your user UID:**
   - Firebase Console → Authentication → Users
   - Copy the UID column value

4. **Run script:**
   ```bash
   npm install firebase-admin
   node set-admin.js
   ```

5. **Force logout/login in app** (required for token refresh)

### Option B: Cloud Function (Production-Ready)

See `docs/setup/ADMIN_SETUP_GUIDE.md` for complete Cloud Function setup.

---

## Step 2: Configure Firebase Storage Rules

Update your Firebase Storage security rules to allow admin writes:

1. **Go to Firebase Console → Storage → Rules**

2. **Add livestock catalog rules:**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // Livestock catalog - admin-managed, user-readable
       match /livestock/{file} {
         // Any authenticated user can read
         allow read: if request.auth != null;
         
         // Only admins can write (publish)
         allow write: if request.auth.token.admin == true;
       }
       
       // Other storage paths...
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. **Publish rules** (Firebase Console saves automatically)

4. **Test rules:**
   ```dart
   // In Flutter app (as admin)
   final ref = FirebaseStorage.instance.ref('livestock/test.json');
   await ref.putString('{"test": true}');
   // Should succeed for admin, fail for regular users
   ```

---

## Step 3: Access Admin Panel

### Direct URL Navigation

After completing Steps 1-2:

1. **Login as admin user** (the one with custom claim)
2. **Navigate to admin panel:**
   - Manually navigate to `/admin/livestock` route
   - Or add a menu item (see below)

### Option: Add Admin Menu Item

To add a menu item visible only to admins:

**In HomePage or Settings:**
```dart
// In HomePage or wherever you have navigation menu
Consumer(
  builder: (context, ref, child) {
    final isAdminAsync = ref.watch(isAdminUserProvider);
    
    return isAdminAsync.when(
      data: (isAdmin) {
        if (isAdmin) {
          return ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin - Catálogo'),
            onTap: () => context.go('/admin/livestock'),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  },
)
```

---

## Step 4: Test Complete Workflow

### Admin Workflow Test

1. **Login as admin user**
   - Ensure custom claim is set and token refreshed (logout/login)

2. **Navigate to `/admin/livestock`**
   - Should see admin panel with "Publicar Catálogo" button
   - Should NOT be redirected to `/home`

3. **Add a test bovine:**
   - Click FAB (+) button
   - Fill form with test data
   - Save

4. **Publish catalog:**
   - Click "Publicar Catálogo" button
   - Confirm in dialog
   - Wait for success message (should see "Catálogo publicado com sucesso!")

5. **Verify in Firebase Storage:**
   - Firebase Console → Storage
   - Check `livestock/` folder
   - Should see: `bovines_catalog.json`, `equines_catalog.json`, `metadata.json`
   - Download and verify JSON structure

### Regular User Workflow Test

1. **Login as regular user** (no admin claim)

2. **Try to access `/admin/livestock`**
   - Should be redirected to `/home`
   - Admin panel should NOT be accessible

3. **Navigate to regular livestock page** (`/home/livestock`)
   - Should auto-sync from Storage on first load
   - Should see the bovine added by admin
   - CRUD buttons should work (writes to local Drift only)

4. **Verify sync behavior:**
   - Check logs for "Syncing catalog from Storage..."
   - SharedPreferences should store last sync timestamp
   - Subsequent loads should skip sync if metadata unchanged

### Expected Behaviors

| Action | Admin User | Regular User |
|--------|-----------|--------------|
| Access `/admin/livestock` | ✅ Allowed | ❌ Redirect to `/home` |
| See "Publicar" button | ✅ Visible | ❌ Not visible |
| Add/Edit bovine | ✅ Saves to Drift local | ✅ Saves to Drift local |
| Click "Publicar" | ✅ Uploads to Storage | N/A |
| Load bovines | ✅ Returns Drift local | ✅ Syncs from Storage → Drift |
| Write to Storage | ✅ Allowed (rules) | ❌ Denied (rules) |

---

## Troubleshooting

### "Admin route redirects to /home"
**Symptoms:** Admin user gets redirected when accessing `/admin/livestock`

**Solutions:**
1. Check custom claim is set:
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   final token = await user?.getIdTokenResult(true);
   print(token?.claims); // Should include {"admin": true}
   ```
2. Force logout/login (token refresh required)
3. Check `isAdminUserProvider` returns `true`:
   ```dart
   final isAdmin = await ref.read(isAdminUserProvider.future);
   print('Is admin: $isAdmin');
   ```

### "Permission denied when publishing"
**Symptoms:** Error when clicking "Publicar Catálogo"

**Solutions:**
1. Verify Storage rules allow admin writes:
   ```javascript
   allow write: if request.auth.token.admin == true;
   ```
2. Check admin claim exists in token (see above)
3. Verify Storage bucket exists and is linked to project

### "Regular users can't see data"
**Symptoms:** Regular users see empty list after sync

**Solutions:**
1. Verify admin published at least once:
   - Check Firebase Storage for JSON files
   - Check `metadata.json` has valid `lastUpdated` timestamp
2. Check user has internet connection (sync requires network)
3. Check Storage rules allow reads:
   ```javascript
   allow read: if request.auth != null;
   ```
4. Check logs for sync errors:
   ```bash
   flutter logs | grep -i "livestock\|sync\|storage"
   ```

### "SharedPreferences error"
**Symptoms:** `Provider.value not initialized` error

**Solutions:**
1. Verify `main.dart` has override:
   ```dart
   final sharedPrefs = await SharedPreferences.getInstance();
   ProviderScope(
     overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
     ...
   )
   ```

---

## Verification Checklist

Before marking as complete, verify:

- [ ] Admin claim set in Firebase Auth (`{"admin": true}`)
- [ ] Storage rules deployed (admin write, user read)
- [ ] Admin can access `/admin/livestock` without redirect
- [ ] Regular users redirected from `/admin/livestock` to `/home`
- [ ] Admin can publish catalog successfully
- [ ] JSON files appear in Firebase Storage after publish
- [ ] Regular users auto-sync on first load
- [ ] Sync timestamp stored in SharedPreferences
- [ ] Subsequent loads skip sync if metadata unchanged
- [ ] Regular users see admin's published data
- [ ] No compilation errors in Flutter app

---

## Cost Analysis Validation

After deployment, monitor costs:

### Expected Costs (1000 users, 100 bovines, 80 equines)

**Firebase Storage:**
- Storage: ~1 MB × $0.026/GB/month = $0.00003/month
- Download: 1 MB × 1000 users × $0.12/GB = $0.12/month
- **Total: ~$0.12/month**

**Firestore (if not migrated):**
- Reads: 180 docs × 1000 users × 100 syncs = 18M reads/month
- Cost: 18M × $0.06/100K = $10.80/month
- **Migration saves: $10.68/month (99% reduction)**

### Monitor in Firebase Console

1. Go to Firebase Console → Storage → Usage
2. Check:
   - Total downloads (should be ~1000/day after release)
   - Storage size (should be ~1 MB)
   - Bandwidth (should be ~1 GB/month)

---

## Next Steps

After successful deployment:

1. **Monitor logs** for first week
   - Watch for sync errors
   - Check publish success rate
   - Monitor Storage bandwidth

2. **Create admin documentation** for content managers
   - How to add/edit livestock
   - How to publish updates
   - When to publish (recommended frequency)

3. **Consider enhancements:**
   - Publish scheduling (auto-publish on save?)
   - Diff view (what changed since last publish?)
   - Rollback capability (version history in Storage?)
   - Multi-admin support (conflict resolution?)

4. **Migrate other features** using same pattern
   - Any read-only catalogs (plants, pests, diseases)
   - Replace Firestore individual docs with Storage JSON
   - Apply same cost optimization strategy

---

## Reference Files

Key implementation files:
- `lib/main.dart` - SharedPreferences override
- `lib/core/router/app_router.dart` - Admin route guard
- `lib/core/auth/user_role_service.dart` - Role checking
- `lib/features/livestock/data/repositories/livestock_repository_impl.dart` - Dual-mode logic
- `lib/features/livestock/data/datasources/livestock_storage_datasource.dart` - Storage operations
- `lib/features/livestock/presentation/pages/admin_livestock_page.dart` - Admin UI
- `lib/features/livestock/presentation/widgets/publish_catalog_button.dart` - Publish button

Documentation:
- `docs/setup/ADMIN_SETUP_GUIDE.md` - Detailed admin setup methods
- `docs/architecture/ADMIN_IN_APP_ARCHITECTURE.md` - Architecture specification
- `docs/architecture/IMPLEMENTATION_COMPLETE.md` - Implementation checklist

---

## Support

If you encounter issues not covered in this guide:

1. Check implementation files for comments and documentation
2. Review `ADMIN_SETUP_GUIDE.md` for detailed setup instructions
3. Verify all steps completed in order
4. Check Firebase Console logs for backend errors
5. Use Flutter DevTools to debug provider state

**Status:** 🟢 Ready for deployment (pending Firebase configuration)
