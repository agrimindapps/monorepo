# Database Repositories (Drift DAOs)

## Purpose
These are **low-level Drift repository implementations** that directly interact with the Drift database. They extend `BaseDriftRepositoryImpl` from the core package and provide CRUD operations and custom queries.

## Architecture
```
database/repositories/ (Drift DAOs)
    ↓ Used by
features/*/data/datasources/ (DataSource wrappers)
    ↓ Used by
features/*/data/repositories/ (Clean Architecture repositories)
    ↓ Used by
Domain Use Cases
```

## Repositories
- **VehicleRepository**: CRUD and queries for vehicles
- **FuelSupplyRepository**: CRUD and queries for fuel records
- **MaintenanceRepository**: CRUD and queries for maintenance records
- **ExpenseRepository**: CRUD and queries for expenses
- **OdometerReadingRepository**: CRUD and queries for odometer readings
- **AuditTrailRepository**: Audit trail logging

## Design Pattern
These repositories follow the **Repository Pattern** at the Drift level, providing a clean abstraction over Drift queries. They handle:
- SQL query generation
- Data mapping (VehicleData ↔ Vehicle)
- Companion object creation for inserts/updates
- Custom queries specific to each entity

## Usage
⚠️ **DO NOT use directly from presentation layer or domain layer**

These should ONLY be used by `features/*/data/datasources/` classes, which then wrap them for use by Clean Architecture repositories.

## Web Support
All repositories check for `_db == null` and return empty results on web, since Drift is not available on web platforms.
