// DEPRECATED: This file is no longer used after migration from Hive to Drift
// Hive adapters are not needed as Drift uses a different approach for data persistence
// This file can be safely deleted once confirmed no dependencies exist

// The original Hive adapter code has been removed as:
// 1. TypeAdapter, BinaryReader, and BinaryWriter are Hive-specific and not available in core package
// 2. The app has migrated from Hive to Drift for local database management
// 3. AnimalModel now uses JSON serialization instead of Hive adapters
