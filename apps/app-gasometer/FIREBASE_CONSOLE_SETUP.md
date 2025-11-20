# Firebase Console Manual Setup Guide - Gasometer Firestore Indices

> 📌 **Quick Links:**
> - **This Guide:** Step-by-step manual index creation via Firebase Console
> - **Automatic Setup:** Run `./deploy-firestore-indexes.sh` instead (recommended)
> - **Full Documentation:** See `FIRESTORE_INDICES.md`
> - **Troubleshooting:** See bottom of this document

---

## Prerequisites

Before starting, ensure:

✅ You have a Firebase project set up
✅ You can access Firebase Console
✅ Your project has Firestore database enabled
✅ Your user has "Editor" or "Firestore Admin" role in the project

### Access Firebase Console

1. Go to [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Sign in with your Google account
3. Select your Gasometer project

---

## Step-by-Step Setup

### Step 1: Navigate to Firestore Indexes

From the main Firebase Console dashboard:

1. **Left Sidebar** → Find and click **"Firestore Database"**

   ```
   Firebase Console
   ├─ Project Overview
   ├─ Build
   │  ├─ Authentication
   │  ├─ Realtime Database
   │  ├─ Firestore Database  ← Click here
   │  ├─ Storage
   │  └─ ...
   ```

2. Once in Firestore, you'll see a top navigation menu:

   ```
   [Data]  [Backups]  [Indexes]  [Rules]  [Usage]  [Settings]
   ```

3. **Click "Indexes"** tab

   Expected screen shows:
   ```
   Firestore Indexes

   Composite Indexes (0)
   [Create Index]  [Import Indexes]

   Single-field indexes
   Automatic: Enable  [Manage...]
   ```

---

### Step 2: Create Index for `vehicles`

**Click the [Create Index] button**

A form will appear:

```
┌─────────────────────────────────────────────────────────┐
│  Create Composite Index                                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Collection ID:  [vehicles________________]             │
│                                                          │
│  Query Scope:    ◯ Collection  ◯ Collection Group       │
│                  (Collection is selected)               │
│                                                          │
│  Fields:                                                │
│  ┌──────────────────────┬──────────────────────┐       │
│  │ Field Name           │ Direction            │       │
│  ├──────────────────────┼──────────────────────┤       │
│  │ [updatedAt_______]   │ [Ascending ▼]        │ [×]   │
│  └──────────────────────┴──────────────────────┘       │
│                                                          │
│  [+ Add field]                                          │
│                                                          │
│  [ Cancel ]  [ Create Index ]                           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Fill in the form:**

1. **Collection ID:** Type `vehicles`
2. **Query Scope:** Keep "Collection" selected
3. **Fields:**
   - First row should have:
     - Field Name: `updatedAt`
     - Direction: `Ascending` (default)

4. Click **[Create Index]** button

**Status:** Index will show "Creating" initially. Wait for it to finish (usually < 5 minutes).

---

### Step 3: Create Index for `fuel_supplies`

Repeat Step 2, but with:

- **Collection ID:** `fuel_supplies`
- **Field:** `updatedAt` (Ascending)

**Form:**
```
Collection ID:  [fuel_supplies___________]
Query Scope:    ◯ Collection  ◯ Collection Group
Fields:
│ Field Name           │ Direction            │
│ [updatedAt_______]   │ [Ascending ▼]        │
```

Click **[Create Index]**

---

### Step 4: Create Index for `maintenances`

Repeat Step 2, but with:

- **Collection ID:** `maintenances`
- **Field:** `updatedAt` (Ascending)

**Form:**
```
Collection ID:  [maintenances__________]
Query Scope:    ◯ Collection  ◯ Collection Group
Fields:
│ Field Name           │ Direction            │
│ [updatedAt_______]   │ [Ascending ▼]        │
```

Click **[Create Index]**

---

### Step 5: Create Index for `expenses`

Repeat Step 2, but with:

- **Collection ID:** `expenses`
- **Field:** `updatedAt` (Ascending)

**Form:**
```
Collection ID:  [expenses________________]
Query Scope:    ◯ Collection  ◯ Collection Group
Fields:
│ Field Name           │ Direction            │
│ [updatedAt_______]   │ [Ascending ▼]        │
```

Click **[Create Index]**

---

### Step 6: Create Index for `odometer_readings`

Repeat Step 2, but with:

- **Collection ID:** `odometer_readings`
- **Field:** `updatedAt` (Ascending)

**Form:**
```
Collection ID:  [odometer_readings______]
Query Scope:    ◯ Collection  ◯ Collection Group
Fields:
│ Field Name           │ Direction            │
│ [updatedAt_______]   │ [Ascending ▼]        │
```

Click **[Create Index]**

---

## Step 7: Verify All Indices

After creating all 5 indices, go back to the **Indexes** tab.

You should see all 5 indices listed:

```
Composite Indexes

| Collection         | Fields                  | Status   |
|____________________|_________________________|__________|
| vehicles           | updatedAt (Ascending)   | Enabled  |
| fuel_supplies      | updatedAt (Ascending)   | Enabled  |
| maintenances       | updatedAt (Ascending)   | Enabled  |
| expenses           | updatedAt (Ascending)   | Enabled  |
| odometer_readings  | updatedAt (Ascending)   | Enabled  |
```

**If status is "Creating":** Wait a few minutes and refresh the page.

**If all show "Enabled":** ✅ Setup is complete!

---

## Troubleshooting

### Problem: Collection ID not found

**Symptom:** Error message: "Collection not found"

**Cause:** The collection hasn't been created yet in Firestore. This is normal - Firestore creates collections on first document write.

**Solution:**
1. Continue with all 5 index definitions
2. When your app syncs data, the collections will be created automatically
3. The indices will be ready when documents arrive

### Problem: "Create Index" button is disabled

**Symptom:** The button is grayed out and can't be clicked

**Possible Causes:**
1. Missing Collection ID (field empty)
2. Missing Field configuration
3. Field name is empty

**Solution:**
1. Verify Collection ID is filled in
2. Verify Field Name is filled in (should be `updatedAt`)
3. Verify Direction is selected (should be "Ascending")

### Problem: Index creation takes > 1 hour

**Symptom:** Index still shows "Creating" after a long time

**Cause:** Firestore is indexing a very large collection

**Solution:**
1. This is expected for collections with millions of documents
2. You can still use the app; queries will be slower until indexing completes
3. Check progress by refreshing the Indexes page

### Problem: Query still fails after index is created

**Symptom:** App still crashes with "index not found" error

**Possible Causes:**
1. Field name mismatch (case-sensitive)
2. Index not yet fully created
3. Query using different collection name

**Verification Steps:**
1. Go to Indexes tab
2. Find your collection in the list
3. Verify status is "Enabled" (not "Creating")
4. Verify field is exactly: `updatedAt` (camelCase, lowercase 'u')
5. In Firebase Console → Data tab, verify your collection name matches exactly

### Problem: Can't find Firestore section in Firebase Console

**Symptom:** No "Firestore Database" option in left sidebar

**Cause:** Your project might be using Realtime Database instead

**Solution:**
1. Go to Project Settings (gear icon)
2. Look for database URL
3. Or create a new Firestore database:
   - Left sidebar → Create new → Select Firestore
   - Choose location and security rules
   - Click Enable

---

## Next Steps After Setup

Once all indices are created and enabled:

1. **Test sync in development:**
   ```bash
   flutter run --debug
   # Use app to sync data
   # Check logs for sync messages
   ```

2. **Monitor in Firebase Console:**
   - Go to Firestore → Usage
   - Monitor "Index Entries Read" metrics
   - Verify queries are using indices (not full collection scans)

3. **Production deployment:**
   - Repeat for production Firebase project
   - Verify all 5 indices are enabled
   - Deploy app to users

---

## Alternative: Import Indices from JSON

If you prefer not to manually create each index:

1. In Indexes tab, look for **[Import Indexes]** button
2. Upload the `firestore.indexes.json` file from this project
3. Firebase will automatically create all 5 indices at once

---

## Additional Resources

- [Firebase Firestore Indices Documentation](https://firebase.google.com/docs/firestore/query-data/index-overview)
- [Firebase Console Help](https://support.google.com/firebase)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

## Quick Summary

| Step | Action | Collection | Field | Expected Time |
|------|--------|-----------|-------|----------------|
| 1 | Create Index | vehicles | updatedAt | 5-10 min |
| 2 | Create Index | fuel_supplies | updatedAt | 5-10 min |
| 3 | Create Index | maintenances | updatedAt | 5-10 min |
| 4 | Create Index | expenses | updatedAt | 5-10 min |
| 5 | Create Index | odometer_readings | updatedAt | 5-10 min |
| 6 | Verify | All | - | Immediate |

**Total Time:** 25-50 minutes (depends on if you do them in parallel)

---

**Last Updated:** 2025-11-19
**Status:** Production Ready
