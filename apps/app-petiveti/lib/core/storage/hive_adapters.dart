import 'package:core/core.dart' show Hive;

/// Registra todos os adapters Hive necessários para o app
/// Deve ser chamado antes de usar qualquer Box
class HiveAdapters {
  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
    }
    if (!Hive.isAdapterRegistered(1)) {
    }
    if (!Hive.isAdapterRegistered(2)) {
    }
    if (!Hive.isAdapterRegistered(3)) {
    }
    if (!Hive.isAdapterRegistered(4)) {
    }
    try {
      if (!Hive.isAdapterRegistered(5)) {
      }
    } catch (e) {
      print('Warning: Could not register ReminderModelAdapter: $e');
    }
    if (!Hive.isAdapterRegistered(6)) {
    }
    if (!Hive.isAdapterRegistered(7)) {
    }
    if (!Hive.isAdapterRegistered(8)) {
    }
    if (!Hive.isAdapterRegistered(9)) {
    }
    _registerEnumAdapters();
  }

  static void _registerEnumAdapters() {
    if (!Hive.isAdapterRegistered(10)) {
    }
    if (!Hive.isAdapterRegistered(11)) {
    }
    if (!Hive.isAdapterRegistered(12)) {
    }
    if (!Hive.isAdapterRegistered(13)) {
    }
    if (!Hive.isAdapterRegistered(14)) {
    }
    if (!Hive.isAdapterRegistered(15)) {
    }
    if (!Hive.isAdapterRegistered(16)) {
    }
    if (!Hive.isAdapterRegistered(17)) {
    }
    if (!Hive.isAdapterRegistered(18)) {
    }
    if (!Hive.isAdapterRegistered(19)) {
    }
    if (!Hive.isAdapterRegistered(20)) {
    }
    if (!Hive.isAdapterRegistered(21)) {
    }
    if (!Hive.isAdapterRegistered(22)) {
    }
    if (!Hive.isAdapterRegistered(23)) {
    }
    if (!Hive.isAdapterRegistered(24)) {
    }
    if (!Hive.isAdapterRegistered(25)) {
    }
    if (!Hive.isAdapterRegistered(26)) {
    }
    if (!Hive.isAdapterRegistered(27)) {
    }
  }
}

/// Nomes dos boxes Hive utilizados no app
class HiveBoxNames {
  static const String animals = 'animals';
  static const String appointments = 'appointments';
  static const String medications = 'medications';
  static const String vaccines = 'vaccines';
  static const String weights = 'weights';
  static const String reminders = 'reminders';
  static const String expenses = 'expenses';
  static const String users = 'users';
  static const String subscriptionPlans = 'subscription_plans';
  static const String userSubscriptions = 'user_subscriptions';
  static const String settings = 'settings';
  static const String cache = 'cache';
  static const String logs = 'logs';
}
