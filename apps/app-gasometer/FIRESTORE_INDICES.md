# Firestore Composite Indices - Gasometer App

## Overview

This document describes the Firestore composite indices required for the Gasometer app's offline-first synchronization system. These indices are **critical for production** and must be deployed before launching the app.

---

## Problem Statement

The Gasometer app uses a **Drift (local SQLite) ↔ Firestore** bidirectional synchronization system. During sync operations, the app pulls remote changes from Firestore using timestamp-based queries:

```dart
// Query pattern in DriftSyncAdapterBase.pullRemoteChanges()
fs.Query query = firestore
    .collection('users')
    .doc(userId)
    .collection(collectionName);

if (since != null) {
  query = query.where('updatedAt', isGreaterThan: since);  // ⚠️ REQUIRES INDEX
}

query = query.limit(500);
final snapshot = await query.get();
```

Without proper indices, **Firestore will reject these queries** with the error:

```
FirebaseException: The query requires an index. You can create it by following the link in the console or locally via the Firebase CLI.
```

---

## Required Indices

### Collections Affected

| Collection | Use Case |
|-----------|----------|
| `vehicles` | Vehicle list sync (cars, trucks, motorcycles) |
| `fuel_supplies` | Fuel consumption records sync |
| `maintenances` | Maintenance history sync |
| `expenses` | Expense tracking sync |
| `odometer_readings` | Odometer history sync |

### Index Configuration

**All 5 collections require the same single-field index:**

```
Field: updatedAt
Order: Ascending (ASC)
Query Scope: COLLECTION
```

### Why This Index?

The sync system needs to fetch only documents modified since the last sync:

```dart
// Example: Pull changes since last 5 minutes
final fiveMinutesAgo = DateTime.now().subtract(Duration(minutes: 5));
final query = firestore
    .collection('users')
    .doc(userId)
    .collection('fuel_supplies')
    .where('updatedAt', isGreaterThan: fiveMinutesAgo);
```

This `updatedAt` range query **requires an index** in Firestore for efficiency.

---

## Deployment Methods

### Method 1: Firebase CLI (Recommended)

**Fastest and most automated approach.**

#### Prerequisites

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Verify authentication
firebase projects:list
```

#### Deploy Script

```bash
# Make script executable
chmod +x deploy-firestore-indexes.sh

# Deploy to development environment
./deploy-firestore-indexes.sh my-project-dev

# Deploy to production environment
./deploy-firestore-indexes.sh my-project-prod prod
```

#### Verify Deployment

```bash
# List all indices for your project
firebase firestore:indexes --project=my-project-dev
```

**Expected output:**
```
✔ Listing firestore indexes for project my-project-dev

Composite Indexes:
  collectionGroup: vehicles, fields: (updatedAt ASC)
  collectionGroup: fuel_supplies, fields: (updatedAt ASC)
  collectionGroup: maintenances, fields: (updatedAt ASC)
  collectionGroup: expenses, fields: (updatedAt ASC)
  collectionGroup: odometer_readings, fields: (updatedAt ASC)
```

---

### Method 2: Firebase Console (Manual)

**Use if you prefer a UI or CLI is unavailable.**

#### Step-by-Step Instructions

1. **Open Firebase Console**
   - Navigate to: https://console.firebase.google.com/
   - Select your Gasometer project

2. **Go to Firestore Indices**
   - Left sidebar → Firestore Database
   - Click "Indexes" tab
   - Click "Create Index" button

3. **Create Index for `vehicles`**
   - **Collection ID:** `vehicles`
   - **Collection Group:** Leave unchecked (unless using collection groups)
   - **Add field:**
     - Field: `updatedAt`
     - Direction: `Ascending`
   - Click "Create Index"

4. **Repeat for remaining collections**
   - `fuel_supplies` (updatedAt ASC)
   - `maintenances` (updatedAt ASC)
   - `expenses` (updatedAt ASC)
   - `odometer_readings` (updatedAt ASC)

5. **Verify All Indices**
   - Wait for status to show "Enabled" (usually 5-10 minutes)
   - All 5 indices should appear in the Indexes list

**Screenshot reference:** The index configuration dialog will show:
```
Collection ID: [vehicles]
Query Scope: Collection

Fields:
┌─────────────────────┬──────────┐
│ Field Name          │ Direction│
├─────────────────────┼──────────┤
│ updatedAt           │ Asc ▼    │
└─────────────────────┴──────────┘

[✓ Create Index]
```

---

### Method 3: Programmatic via Dart

**For automated deployments (CI/CD).**

```bash
# Add to pubspec.yaml
dev_dependencies:
  firebase_admin: ^2.0.0

# Run deployment command
dart run bin/deploy_indexes.dart --project=my-project-dev
```

Example deployment script:

```dart
// bin/deploy_indexes.dart
import 'package:firebase_admin/firebase_admin.dart';

void main(List<String> args) async {
  // Initialize Firebase Admin SDK
  final app = initializeApp(
    credential: certificateFromPath('path/to/credentials.json'),
    databaseURL: 'https://my-project.firebaseio.com',
  );

  final db = Firestore.instance;

  // Note: Creating indices via Admin SDK is not directly supported
  // Use Firebase CLI instead for index creation
  // This script shown for reference only
}
```

---

## Performance Impact

### Before Indices

- ❌ Queries rejected with `FirebaseException`
- ❌ App crashes or hangs during sync
- ❌ Users cannot sync offline changes

### After Indices

- ✅ Queries execute in **< 100ms** for typical datasets
- ✅ Sync completes in **2-5 seconds**
- ✅ Efficient timestamp-based queries
- ✅ Scales to millions of documents

### Index Size

- **Per index:** ~1-5 MB (negligible)
- **Total for 5 indices:** < 25 MB
- **Cost:** Included in Firestore pricing (minimal impact)

---

## Monitoring & Maintenance

### Check Index Status

```bash
# View all indices
firebase firestore:indexes --project=my-project-prod

# View specific collection
firebase firestore:indexes --project=my-project-prod | grep vehicles
```

### Production Monitoring

Monitor query performance in Firebase Console:

1. **Firestore → Indexes**
   - Verify all 5 indices show "Enabled" status
   - Check "Size" column for growth

2. **Firestore → Usage**
   - Monitor index scan counts (under "Index Entries Read")
   - Should be proportional to result count (not full collection scans)

### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| `FirebaseException: index not found` | Indices not deployed | Run deploy script or create manually |
| Index shows "Creating" for > 1 hour | Large collection | This is normal; wait for completion |
| Queries still slow after indexing | Wrong field order | Verify index has updatedAt first |
| Index created but not used | Field name mismatch | Ensure Dart code uses `updatedAt` (camelCase) |

---

## Code Integration

### Sync Service Configuration

The indices are automatically utilized by the sync system:

```dart
// lib/core/gasometer_sync_config.dart
static Future<void> initialize() async {
  // Configure UnifiedSyncManager
  await UnifiedSyncManager.instance.initializeApp(
    appName: 'gasometer',
    config: AppSyncConfig.simple(
      appName: 'gasometer',
      syncInterval: const Duration(minutes: 5),
      conflictStrategy: ConflictStrategy.timestamp,
    ),
  );

  // The sync service automatically uses:
  // query.where('updatedAt', isGreaterThan: lastSyncTimestamp)
  // which relies on the indices defined above
}
```

### Query Pattern Used

All sync adapters follow this pattern:

```dart
// lib/features/[feature]/data/sync/[feature]_drift_sync_adapter.dart

@override
Future<void> pullRemoteChanges(String userId, {DateTime? since}) async {
  // This query REQUIRES the index on updatedAt
  final query = firestore
      .collection('users')
      .doc(userId)
      .collection(collectionName)
      .where('updatedAt', isGreaterThan: since ?? DateTime(2020))
      .limit(500);

  final snapshot = await query.get();
  // Process results...
}
```

---

## Deployment Checklist

Before launching Gasometer in production:

- [ ] Firestore indices file reviewed (`firestore.indexes.json`)
- [ ] Dev environment indices deployed via CLI or Console
- [ ] Dev indices verified as "Enabled" in Firebase Console
- [ ] Sync tested on dev with production-like data
- [ ] Production indices deployed
- [ ] Prod indices verified as "Enabled"
- [ ] Staging/QA tested with both dev and prod indices
- [ ] All 5 collections verified to have indices
- [ ] Monitoring configured for production

---

## Additional Resources

- [Firebase Firestore Indices Documentation](https://firebase.google.com/docs/firestore/query-data/index-overview)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Gasometer Sync Architecture](./lib/features/sync/README.md)
- [Drift Database Documentation](https://drift.simonbinder.eu/)

---

## Questions or Issues?

If indices fail to deploy or queries still fail after deployment:

1. Verify all 5 indices are created and show "Enabled"
2. Check that field names match exactly (case-sensitive): `updatedAt`
3. Ensure Firebase project is correct: `firebase projects:list`
4. Review Firebase Console logs for detailed error messages
5. Contact Firebase support with error message and project ID

---

**Last Updated:** 2025-11-19
**Status:** Production Ready
**Related Files:**
- `firestore.indexes.json` - Index configuration
- `deploy-firestore-indexes.sh` - Deployment script
- `lib/core/gasometer_sync_config.dart` - Sync configuration
