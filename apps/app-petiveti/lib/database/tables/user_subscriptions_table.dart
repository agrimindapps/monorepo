import 'package:drift/drift.dart';

/// Tabela de assinaturas (cache local com Drift)
@DataClassName('UserSubscription')
class UserSubscriptions extends Table {
  // Primary key
  TextColumn get id => text()();

  // User reference
  TextColumn get userId => text()();

  // Subscription data (encrypted sensitive fields)
  TextColumn get productId => text()(); // Encrypted
  TextColumn get status => text()(); // Encrypted (SubscriptionStatus enum name)
  TextColumn get tier => text()(); // Encrypted (SubscriptionTier enum name)
  TextColumn get store => text()(); // Store enum name (appStore/playStore)

  // Dates
  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get originalPurchaseDate => dateTime().nullable()();

  // Metadata
  BoolColumn get isSandbox => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Sync fields
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, productId}, // Unique per user+product
  ];
}
