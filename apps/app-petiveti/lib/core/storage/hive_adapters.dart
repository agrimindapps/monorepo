import 'package:hive/hive.dart';

/// Registra todos os adapters Hive necessários para o app
/// Deve ser chamado antes de usar qualquer Box
class HiveAdapters {
  static void registerAdapters() {
    // Note: LogEntry adapters will be registered when generated
    // For now, we'll initialize without them and handle in LogLocalDataSourceImpl
    // Animals - TypeAdapter 0
    if (!Hive.isAdapterRegistered(0)) {
      // Hive.registerAdapter(AnimalModelAdapter());
    }

    // Appointments - TypeAdapter 1
    if (!Hive.isAdapterRegistered(1)) {
      // Hive.registerAdapter(AppointmentModelAdapter());
    }

    // Medications - TypeAdapter 2
    if (!Hive.isAdapterRegistered(2)) {
      // Hive.registerAdapter(MedicationModelAdapter());
    }

    // Vaccines - TypeAdapter 3
    if (!Hive.isAdapterRegistered(3)) {
      // Hive.registerAdapter(VaccineModelAdapter());
    }

    // Weight - TypeAdapter 4
    if (!Hive.isAdapterRegistered(4)) {
      // Hive.registerAdapter(WeightModelAdapter());
    }

    // Reminders - TypeAdapter 5 (Conditionally registered)
    try {
      if (!Hive.isAdapterRegistered(5)) {
        // Hive.registerAdapter(ReminderModelAdapter());
      }
    } catch (e) {
      print('Warning: Could not register ReminderModelAdapter: $e');
    }

    // Expenses - TypeAdapter 6
    if (!Hive.isAdapterRegistered(6)) {
      // Hive.registerAdapter(ExpenseModelAdapter());
    }

    // Auth User - TypeAdapter 7
    if (!Hive.isAdapterRegistered(7)) {
      // Hive.registerAdapter(UserModelAdapter());
    }

    // Subscription Plan - TypeAdapter 8
    if (!Hive.isAdapterRegistered(8)) {
      // Hive.registerAdapter(SubscriptionPlanModelAdapter());
    }

    // User Subscription - TypeAdapter 9
    if (!Hive.isAdapterRegistered(9)) {
      // Hive.registerAdapter(UserSubscriptionModelAdapter());
    }

    // Enums - TypeAdapters 10-20
    _registerEnumAdapters();
  }

  static void _registerEnumAdapters() {
    // Animals enums - 10-12
    if (!Hive.isAdapterRegistered(10)) {
      // Hive.registerAdapter(AnimalSpeciesAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      // Hive.registerAdapter(AnimalGenderAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      // Hive.registerAdapter(AnimalSizeAdapter());
    }

    // Appointments enums - 13-14
    if (!Hive.isAdapterRegistered(13)) {
      // Hive.registerAdapter(AppointmentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      // Hive.registerAdapter(AppointmentStatusAdapter());
    }

    // Medications enums - 15-16
    if (!Hive.isAdapterRegistered(15)) {
      // Hive.registerAdapter(MedicationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      // Hive.registerAdapter(MedicationStatusAdapter());
    }

    // Vaccines enums - 17-18
    if (!Hive.isAdapterRegistered(17)) {
      // Hive.registerAdapter(VaccineTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      // Hive.registerAdapter(VaccineStatusAdapter());
    }

    // Reminders enums - 19-22
    if (!Hive.isAdapterRegistered(19)) {
      // Hive.registerAdapter(ReminderTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      // Hive.registerAdapter(ReminderPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      // Hive.registerAdapter(ReminderStatusAdapter());
    }

    // Expenses enums - 22-23
    if (!Hive.isAdapterRegistered(22)) {
      // Hive.registerAdapter(ExpenseCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      // Hive.registerAdapter(PaymentMethodAdapter());
    }

    // Auth enums - 24-25
    if (!Hive.isAdapterRegistered(24)) {
      // Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      // Hive.registerAdapter(AuthProviderAdapter());
    }

    // Subscription enums - 26-27
    if (!Hive.isAdapterRegistered(26)) {
      // Hive.registerAdapter(PlanTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      // Hive.registerAdapter(PlanStatusAdapter());
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