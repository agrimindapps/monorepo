import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/failures.dart';
import '../../core/interfaces/usecase.dart';
import '../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../features/animals/data/datasources/animal_remote_datasource.dart';
import '../../features/animals/data/models/animal_model.dart';
import '../../features/animals/data/repositories/animal_repository_hybrid_impl.dart';
import '../../features/animals/domain/repositories/animal_repository.dart';
import '../../features/animals/domain/usecases/add_animal.dart';
import '../../features/animals/domain/usecases/delete_animal.dart';
import '../../features/animals/domain/usecases/get_animal_by_id.dart';
import '../../features/animals/domain/usecases/get_animals.dart';
import '../../features/animals/domain/usecases/update_animal.dart';
import '../../features/appointments/data/datasources/appointment_local_datasource.dart';
import '../../features/appointments/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/entities/appointment.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/add_appointment.dart';
import '../../features/appointments/domain/usecases/delete_appointment.dart';
import '../../features/appointments/domain/usecases/get_appointment_by_id.dart';
import '../../features/appointments/domain/usecases/get_appointments.dart';
import '../../features/appointments/domain/usecases/get_upcoming_appointments.dart';
import '../../features/appointments/domain/usecases/update_appointment.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/calculators/data/datasources/calculator_local_datasource.dart';
import '../../features/calculators/data/repositories/calculator_repository_impl.dart';
import '../../features/calculators/data/repositories/medication_database.dart';
import '../../features/calculators/domain/repositories/calculator_repository.dart';
import '../../features/calculators/domain/strategies/body_condition_strategy.dart';
import '../../features/calculators/domain/strategies/calorie_calculator_strategy.dart';
import '../../features/calculators/domain/strategies/medication_dosage_strategy.dart';
import '../../features/calculators/domain/usecases/get_calculators.dart';
import '../../features/calculators/domain/usecases/manage_calculation_history.dart';
import '../../features/calculators/domain/usecases/manage_favorites.dart';
import '../../features/calculators/domain/usecases/perform_calculation.dart';
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_hybrid_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/expense_usecases.dart';
import '../../features/medications/data/datasources/medication_local_datasource.dart';
import '../../features/medications/data/repositories/medication_repository_local_only_impl.dart';
import '../../features/medications/domain/repositories/medication_repository.dart';
import '../../features/medications/domain/usecases/add_medication.dart';
import '../../features/medications/domain/usecases/delete_medication.dart'
    show DeleteMedication, DiscontinueMedication;
import '../../features/medications/domain/usecases/get_active_medications.dart';
import '../../features/medications/domain/usecases/get_expiring_medications.dart';
import '../../features/medications/domain/usecases/get_medication_by_id.dart';
import '../../features/medications/domain/usecases/get_medications.dart';
import '../../features/medications/domain/usecases/get_medications_by_animal_id.dart';
import '../../features/medications/domain/usecases/update_medication.dart';
import '../../features/reminders/data/datasources/reminder_local_datasource.dart';
import '../../features/reminders/data/datasources/reminder_remote_datasource.dart';
import '../../features/reminders/data/models/reminder_model.dart';
import '../../features/reminders/data/repositories/reminder_repository_hybrid_impl.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/domain/usecases/add_reminder.dart';
import '../../features/reminders/domain/usecases/delete_reminder.dart';
import '../../features/reminders/domain/usecases/get_reminders.dart';
import '../../features/reminders/domain/usecases/update_reminder.dart';
import '../../features/subscription/data/datasources/subscription_local_datasource.dart';
import '../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/domain/usecases/subscription_usecases.dart';
import '../../features/promo/data/repositories/promo_repository_impl.dart';
import '../../features/promo/domain/repositories/promo_repository.dart';
import '../../features/promo/domain/usecases/get_promo_content.dart';
import '../../features/promo/domain/usecases/submit_pre_registration.dart';
import '../../features/promo/domain/usecases/track_analytics.dart';
import '../../features/vaccines/data/datasources/vaccine_local_datasource.dart';
import '../../features/vaccines/data/datasources/vaccine_remote_datasource.dart';
import '../../features/vaccines/data/repositories/vaccine_repository_impl.dart';
import '../../features/vaccines/domain/entities/vaccine.dart';
import '../../features/vaccines/domain/repositories/vaccine_repository.dart';
import '../../features/vaccines/domain/usecases/add_vaccine.dart';
import '../../features/vaccines/domain/usecases/delete_vaccine.dart';
import '../../features/vaccines/domain/usecases/get_overdue_vaccines.dart';
import '../../features/vaccines/domain/usecases/get_upcoming_vaccines.dart';
import '../../features/vaccines/domain/usecases/get_vaccine_by_id.dart';
import '../../features/vaccines/domain/usecases/get_vaccine_calendar.dart';
import '../../features/vaccines/domain/usecases/get_vaccine_statistics.dart';
import '../../features/vaccines/domain/usecases/get_vaccines.dart';
import '../../features/vaccines/domain/usecases/get_vaccines_by_animal.dart';
import '../../features/vaccines/domain/usecases/mark_vaccine_completed.dart';
import '../../features/vaccines/domain/usecases/schedule_vaccine_reminder.dart';
import '../../features/vaccines/domain/usecases/search_vaccines.dart';
import '../../features/vaccines/domain/usecases/update_vaccine.dart';
import '../../features/weight/data/datasources/weight_local_datasource.dart';
import '../../features/weight/data/repositories/weight_repository_impl.dart';
import '../../features/weight/domain/repositories/weight_repository.dart';
import '../../features/weight/domain/usecases/add_weight.dart';
import '../../features/weight/domain/usecases/get_weight_statistics.dart';
import '../../features/weight/domain/usecases/get_weights.dart';
import '../../features/weight/domain/usecases/get_weights_by_animal_id.dart';
import '../../features/weight/domain/usecases/update_weight.dart';
import '../auth/auth_service.dart';
import '../cache/cache_service.dart';
import '../logging/datasources/log_local_datasource.dart';
import '../logging/datasources/log_local_datasource_simple_impl.dart';
import '../logging/repositories/log_repository.dart';
import '../logging/repositories/log_repository_impl.dart';
import '../logging/services/logging_service.dart';
import '../notifications/notification_service.dart';
import '../optimization/lazy_loader.dart';
import '../performance/performance_service.dart' as local_perf;
import '../storage/hive_service.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Initialize Hive with all adapters and boxes
  await HiveService.instance.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // External services
  _registerExternalServices();

  // Core services
  _registerCoreServices();

  // Features services (always register auth, but with mocks in web debug)
  _registerAuthFeature();

  // Skip Firebase-dependent features in web debug (except reminders which has local fallback)
  if (!kIsWeb || !kDebugMode) {
    _registerSubscriptionFeature();
    _registerAppointmentsFeature();
    _registerVaccinesFeature();
    _registerExpensesFeature();
  } else {
    // Register mock appointments and vaccines for web debug
    _registerMockAppointmentsFeature();
    _registerMockVaccinesFeature();
  }

  // Always register reminders feature as it has local fallback implementation
  _registerRemindersFeature();

  // Always register non-Firebase features
  _registerAnimalsFeature(); // Uses only Hive
  _registerMedicationsFeature(); // Local only
  _registerWeightFeature(); // Local only
  _registerCalculatorsFeature(); // No Firebase
  _registerPromoFeature(); // Promotional page feature

  // Core services that depend on features (skip in web debug)
  if (!kIsWeb || !kDebugMode) {
    _registerCoreAuthServices();
  }

  // Initialize logging service after all dependencies are registered
  await _initializeLoggingService();
}

Future<void> _initializeLoggingService() async {
  try {
    // Skip Firebase services in web debug mode
    if (kIsWeb && kDebugMode) {
      await LoggingService.instance.initialize(
        logRepository: getIt<LogRepository>(),
        analytics: null,
        crashlytics: null,
      );
    } else {
      await LoggingService.instance.initialize(
        logRepository: getIt<LogRepository>(),
        analytics: getIt<FirebaseAnalytics>(),
        crashlytics: getIt<FirebaseCrashlytics>(),
      );
    }
  } catch (e) {
    // If logging service fails to initialize, continue without it
    print('Warning: Failed to initialize LoggingService: $e');
  }
}

void _registerExternalServices() {
  // Connectivity
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Skip Firebase registration on web debug to avoid JavaScript errors
  if (!kIsWeb || !kDebugMode) {
    // Firebase Auth
    getIt.registerLazySingleton<firebase_auth.FirebaseAuth>(
      () => firebase_auth.FirebaseAuth.instance,
    );

    // Firebase Firestore
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    // Firebase Analytics
    getIt.registerLazySingleton<FirebaseAnalytics>(
      () => FirebaseAnalytics.instance,
    );

    // Firebase Crashlytics
    getIt.registerLazySingleton<FirebaseCrashlytics>(
      () => FirebaseCrashlytics.instance,
    );
  }

  // Google Sign In
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // RevenueCat Purchases - Register as Type since it has static methods
  // Note: RevenueCat Purchases is accessed statically, not as instance
  // getIt.registerLazySingleton<Purchases>(() => Purchases); // Not needed for static API
}

void _registerCoreServices() {
  // Hive Service
  getIt.registerLazySingleton<HiveService>(() => HiveService.instance);

  // Logging Services
  getIt.registerLazySingleton<LogLocalDataSource>(
    () => LogLocalDataSourceSimpleImpl(),
  );

  getIt.registerLazySingleton<LogRepository>(
    () => LogRepositoryImpl(localDataSource: getIt<LogLocalDataSource>()),
  );

  // Notification Service
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Cache Service
  getIt.registerLazySingleton<CacheService>(() => CacheService());

  // Performance Service (Local)
  getIt.registerLazySingleton<local_perf.PerformanceService>(
    () => local_perf.PerformanceService(),
  );

  // Lazy Loader
  getIt.registerLazySingleton<LazyLoader>(() => LazyLoader());
}

void _registerAuthFeature() {
  // Data Sources - local always works
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () =>
        AuthLocalDataSourceImpl(sharedPreferences: getIt<SharedPreferences>()),
  );

  // Mock remote data source and repository for web debug to avoid Firebase errors
  if (kIsWeb && kDebugMode) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => _MockAuthRemoteDataSource(),
    );

    getIt.registerLazySingleton<AuthRepository>(() => _MockAuthRepository());

    // Mock Use Cases for web debug
    getIt.registerLazySingleton<SignInWithEmail>(() => _MockSignInWithEmail());

    getIt.registerLazySingleton<SignUpWithEmail>(() => _MockSignUpWithEmail());

    getIt.registerLazySingleton<SignInWithGoogle>(
      () => _MockSignInWithGoogle(),
    );

    getIt.registerLazySingleton<SignInWithApple>(() => _MockSignInWithApple());

    getIt.registerLazySingleton<SignInWithFacebook>(
      () => _MockSignInWithFacebook(),
    );

    getIt.registerLazySingleton<SignInAnonymously>(
      () => _MockSignInAnonymously(),
    );

    getIt.registerLazySingleton<SignOut>(() => _MockSignOut());

    getIt.registerLazySingleton<GetCurrentUser>(() => _MockGetCurrentUser());

    getIt.registerLazySingleton<SendEmailVerification>(
      () => _MockSendEmailVerification(),
    );

    getIt.registerLazySingleton<SendPasswordResetEmail>(
      () => _MockSendPasswordResetEmail(),
    );

    getIt.registerLazySingleton<UpdateProfile>(() => _MockUpdateProfile());

    getIt.registerLazySingleton<DeleteAccount>(() => _MockDeleteAccount());
  } else {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: firebase_auth.FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        googleSignIn: getIt<GoogleSignIn>(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        localDataSource: getIt<AuthLocalDataSource>(),
        remoteDataSource: getIt<AuthRemoteDataSource>(),
      ),
    );

    // Real Use Cases
    getIt.registerLazySingleton<SignInWithEmail>(
      () => SignInWithEmail(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignUpWithEmail>(
      () => SignUpWithEmail(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignInWithGoogle>(
      () => SignInWithGoogle(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignInWithApple>(
      () => SignInWithApple(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignInWithFacebook>(
      () => SignInWithFacebook(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignInAnonymously>(
      () => SignInAnonymously(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignOut>(
      () => SignOut(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUser(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SendEmailVerification>(
      () => SendEmailVerification(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SendPasswordResetEmail>(
      () => SendPasswordResetEmail(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<UpdateProfile>(
      () => UpdateProfile(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<DeleteAccount>(
      () => DeleteAccount(getIt<AuthRepository>()),
    );
  }
}

void _registerAnimalsFeature() {
  // Data Sources
  getIt.registerLazySingleton<AnimalLocalDataSource>(
    () => AnimalLocalDataSourceImpl(getIt<HiveService>()),
  );

  // Mock remote datasource for web debug to avoid Firebase errors
  if (kIsWeb && kDebugMode) {
    getIt.registerLazySingleton<AnimalRemoteDataSource>(
      () => _MockAnimalRemoteDataSource(),
    );
  } else {
    getIt.registerLazySingleton<AnimalRemoteDataSource>(
      () => AnimalRemoteDataSourceImpl(),
    );
  }

  // Repository (hybrid with local + remote sync, or local-only in web debug)
  if (kIsWeb && kDebugMode) {
    // Use local-only implementation for web debug
    getIt.registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryHybridImpl(
        localDataSource: getIt<AnimalLocalDataSource>(),
        remoteDataSource: getIt<AnimalRemoteDataSource>(),
        connectivity: getIt<Connectivity>(),
      ),
    );
  } else {
    getIt.registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryHybridImpl(
        localDataSource: getIt<AnimalLocalDataSource>(),
        remoteDataSource: getIt<AnimalRemoteDataSource>(),
        connectivity: getIt<Connectivity>(),
      ),
    );
  }

  // Use Cases
  getIt.registerLazySingleton<GetAnimals>(
    () => GetAnimals(getIt<AnimalRepository>()),
  );

  getIt.registerLazySingleton<GetAnimalById>(
    () => GetAnimalById(getIt<AnimalRepository>()),
  );

  getIt.registerLazySingleton<AddAnimal>(
    () => AddAnimal(getIt<AnimalRepository>()),
  );

  getIt.registerLazySingleton<UpdateAnimal>(
    () => UpdateAnimal(getIt<AnimalRepository>()),
  );

  getIt.registerLazySingleton<DeleteAnimal>(
    () => DeleteAnimal(getIt<AnimalRepository>()),
  );
}

void _registerAppointmentsFeature() {
  // Data Sources
  getIt.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(firestore: getIt()),
  );

  // Repository (hybrid with local + remote sync)
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      localDataSource: getIt<AppointmentLocalDataSource>(),
      remoteDataSource: getIt<AppointmentRemoteDataSource>(),
      connectivity: getIt<Connectivity>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetAppointments>(
    () => GetAppointments(getIt<AppointmentRepository>()),
  );

  getIt.registerLazySingleton<GetUpcomingAppointments>(
    () => GetUpcomingAppointments(getIt<AppointmentRepository>()),
  );

  getIt.registerLazySingleton<GetAppointmentById>(
    () => GetAppointmentById(getIt<AppointmentRepository>()),
  );

  getIt.registerLazySingleton<AddAppointment>(
    () => AddAppointment(getIt<AppointmentRepository>()),
  );

  getIt.registerLazySingleton<UpdateAppointment>(
    () => UpdateAppointment(getIt<AppointmentRepository>()),
  );

  getIt.registerLazySingleton<DeleteAppointment>(
    () => DeleteAppointment(getIt<AppointmentRepository>()),
  );
}

void _registerVaccinesFeature() {
  // Data Sources
  getIt.registerLazySingleton<VaccineLocalDataSource>(
    () => VaccineLocalDataSourceImpl(getIt<HiveService>()),
  );

  getIt.registerLazySingleton<VaccineRemoteDataSource>(
    () => VaccineRemoteDataSourceImpl(
      getIt<FirebaseFirestore>(),
      'current_user', // TODO: Get actual user ID from auth service
    ),
  );

  // Repository (local + remote)
  getIt.registerLazySingleton<VaccineRepository>(
    () => VaccineRepositoryImpl(
      localDataSource: getIt<VaccineLocalDataSource>(),
      remoteDataSource: getIt<VaccineRemoteDataSource>(),
    ),
  );

  // Use Cases - Basic CRUD
  getIt.registerLazySingleton<GetVaccines>(
    () => GetVaccines(getIt<VaccineRepository>()),
  );

  getIt.registerLazySingleton<AddVaccine>(
    () => AddVaccine(getIt<VaccineRepository>()),
  );

  // Use Cases - Advanced (need to be registered when implemented)
  /*
  getIt.registerLazySingleton<GetOverdueVaccines>(
    () => GetOverdueVaccines(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<GetUpcomingVaccines>(
    () => GetUpcomingVaccines(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<GetVaccineStatistics>(
    () => GetVaccineStatistics(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<GetVaccineById>(
    () => GetVaccineById(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<UpdateVaccine>(
    () => UpdateVaccine(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<DeleteVaccine>(
    () => DeleteVaccine(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<MarkVaccineCompleted>(
    () => MarkVaccineCompleted(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<ScheduleVaccineReminder>(
    () => ScheduleVaccineReminder(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<SearchVaccines>(
    () => SearchVaccines(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<GetVaccinesByAnimal>(
    () => GetVaccinesByAnimal(getIt<VaccineRepository>()),
  );
  
  getIt.registerLazySingleton<GetVaccineCalendar>(
    () => GetVaccineCalendar(getIt<VaccineRepository>()),
  );
  */
}

void _registerMedicationsFeature() {
  // Data Sources
  getIt.registerLazySingleton<MedicationLocalDataSource>(
    () => MedicationLocalDataSourceImpl(),
  );

  // Repository (local-only for now)
  getIt.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryLocalOnlyImpl(
      localDataSource: getIt<MedicationLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetMedications>(
    () => GetMedications(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<GetMedicationsByAnimalId>(
    () => GetMedicationsByAnimalId(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<GetActiveMedications>(
    () => GetActiveMedications(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<GetActiveMedicationsByAnimalId>(
    () => GetActiveMedicationsByAnimalId(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<GetMedicationById>(
    () => GetMedicationById(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<AddMedication>(
    () => AddMedication(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<UpdateMedication>(
    () => UpdateMedication(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<DeleteMedication>(
    () => DeleteMedication(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<DiscontinueMedication>(
    () => DiscontinueMedication(getIt<MedicationRepository>()),
  );

  getIt.registerLazySingleton<GetExpiringSoonMedications>(
    () => GetExpiringSoonMedications(getIt<MedicationRepository>()),
  );
}

void _registerWeightFeature() {
  // Data Sources
  getIt.registerLazySingleton<WeightLocalDataSource>(
    () => WeightLocalDataSourceImpl(),
  );

  // Repository (local-only for now)
  getIt.registerLazySingleton<WeightRepository>(
    () => WeightRepositoryImpl(localDataSource: getIt<WeightLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<GetWeights>(
    () => GetWeights(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetWeightsByAnimalId>(
    () => GetWeightsByAnimalId(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<AddWeight>(
    () => AddWeight(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetWeightStatistics>(
    () => GetWeightStatistics(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<UpdateWeight>(
    () => UpdateWeight(getIt<WeightRepository>()),
  );
}

void _registerRemindersFeature() {
  // Data Sources
  getIt.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(),
  );

  // Mock remote datasource for web debug to avoid Firebase errors
  if (kIsWeb && kDebugMode) {
    getIt.registerLazySingleton<ReminderRemoteDataSource>(
      () => _MockReminderRemoteDataSource(),
    );
  } else {
    getIt.registerLazySingleton<ReminderRemoteDataSource>(
      () => ReminderRemoteDataSourceImpl(),
    );
  }

  // Repository (hybrid with local + remote sync)
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryHybridImpl(
      localDataSource: getIt<ReminderLocalDataSource>(),
      remoteDataSource: getIt<ReminderRemoteDataSource>(),
      connectivity: getIt<Connectivity>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetReminders>(
    () => GetReminders(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<GetTodayReminders>(
    () => GetTodayReminders(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<GetOverdueReminders>(
    () => GetOverdueReminders(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<AddReminder>(
    () => AddReminder(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<UpdateReminder>(
    () => UpdateReminder(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<CompleteReminder>(
    () => CompleteReminder(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<SnoozeReminder>(
    () => SnoozeReminder(getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<DeleteReminder>(
    () => DeleteReminder(getIt<ReminderRepository>()),
  );
}

void _registerExpensesFeature() {
  // Data Sources
  getIt.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(),
  );

  // Repository (hybrid with local + remote sync)
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryHybridImpl(
      localDataSource: getIt<ExpenseLocalDataSource>(),
      remoteDataSource: getIt<ExpenseRemoteDataSource>(),
      connectivity: getIt<Connectivity>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetExpenses>(
    () => GetExpenses(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetExpensesByAnimal>(
    () => GetExpensesByAnimal(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetExpensesByDateRange>(
    () => GetExpensesByDateRange(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetExpensesByCategory>(
    () => GetExpensesByCategory(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetExpenseSummary>(
    () => GetExpenseSummary(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<AddExpense>(
    () => AddExpense(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<UpdateExpense>(
    () => UpdateExpense(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<DeleteExpense>(
    () => DeleteExpense(getIt<ExpenseRepository>()),
  );
}

void _registerSubscriptionFeature() {
  // Data Sources
  getIt.registerLazySingleton<SubscriptionLocalDataSource>(
    () => SubscriptionLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      // RevenueCat Purchases is accessed statically, not injected
    ),
  );

  // Repository
  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      localDataSource: getIt<SubscriptionLocalDataSource>(),
      remoteDataSource: getIt<SubscriptionRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetAvailablePlans>(
    () => GetAvailablePlans(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentSubscription>(
    () => GetCurrentSubscription(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<SubscribeToPlan>(
    () => SubscribeToPlan(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<CancelSubscription>(
    () => CancelSubscription(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<PauseSubscription>(
    () => PauseSubscription(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<ResumeSubscription>(
    () => ResumeSubscription(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<UpgradePlan>(
    () => UpgradePlan(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<RestorePurchases>(
    () => RestorePurchases(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton<ValidateReceipt>(
    () => ValidateReceipt(getIt<SubscriptionRepository>()),
  );
}

void _registerCalculatorsFeature() {
  // Data Sources
  getIt.registerLazySingleton<CalculatorLocalDatasource>(
    () => CalculatorLocalDatasourceImpl(getIt<HiveService>()),
  );

  // Repositories
  getIt.registerLazySingleton<CalculatorRepository>(
    () => CalculatorRepositoryImpl(getIt<CalculatorLocalDatasource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<GetCalculators>(
    () => GetCalculators(getIt<CalculatorRepository>()),
  );

  getIt.registerLazySingleton<GetCalculatorsByCategory>(
    () => GetCalculatorsByCategory(getIt<CalculatorRepository>()),
  );

  getIt.registerLazySingleton<GetCalculatorById>(
    () => GetCalculatorById(getIt<CalculatorRepository>()),
  );

  getIt.registerLazySingleton<PerformCalculation>(
    () => PerformCalculation(getIt<CalculatorRepository>()),
  );

  getIt.registerLazySingleton<ManageCalculationHistory>(
    () => ManageCalculationHistory(getIt<CalculatorRepository>()),
  );

  getIt.registerLazySingleton<ManageFavorites>(
    () => ManageFavorites(getIt<CalculatorRepository>()),
  );

  // Strategies
  getIt.registerLazySingleton<BodyConditionStrategy>(
    () => const BodyConditionStrategy(),
  );

  getIt.registerLazySingleton<CalorieCalculatorStrategy>(
    () => CalorieCalculatorStrategy(),
  );

  getIt.registerLazySingleton<MedicationDosageStrategy>(
    () => MedicationDosageStrategy(MedicationDatabase.getAllMedications()),
  );
}

void _registerCoreAuthServices() {
  // Auth Service that combines Auth and Subscription
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      authRepository: getIt<AuthRepository>(),
      subscriptionRepository: getIt<SubscriptionRepository>(),
    ),
  );
}

void _registerPromoFeature() {
  // Repository
  getIt.registerLazySingleton<PromoRepository>(
    () => const PromoRepositoryImpl(),
  );

  // Use Cases
  getIt.registerLazySingleton<GetPromoContent>(
    () => GetPromoContent(getIt<PromoRepository>()),
  );

  getIt.registerLazySingleton<SubmitPreRegistration>(
    () => SubmitPreRegistration(getIt<PromoRepository>()),
  );

  getIt.registerLazySingleton<TrackAnalytics>(
    () => TrackAnalytics(getIt<PromoRepository>()),
  );
}

/// Mock AnimalRemoteDataSource for web debug mode
class _MockAnimalRemoteDataSource implements AnimalRemoteDataSource {
  @override
  Future<List<AnimalModel>> getAnimals(String userId) async {
    // Return empty list in debug mode
    return [];
  }

  @override
  Future<AnimalModel?> getAnimalById(String id) async {
    // Return null in debug mode
    return null;
  }

  @override
  Future<String> addAnimal(AnimalModel animal, String userId) async {
    // Return fake ID in debug mode
    return 'mock_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> updateAnimal(AnimalModel animal) async {
    // Do nothing in debug mode
    return;
  }

  @override
  Future<void> deleteAnimal(String id) async {
    // Do nothing in debug mode
    return;
  }

  @override
  Stream<List<AnimalModel>> streamAnimals(String userId) {
    // Return empty stream in debug mode
    return Stream.value([]);
  }

  @override
  Stream<AnimalModel?> streamAnimal(String id) {
    // Return null stream in debug mode
    return Stream.value(null);
  }
}

// Mock Auth implementations for web debug mode
class _MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    // Return mock user for debug mode
    return _createMockUser();
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    // Return mock user for debug mode
    return _createMockUser();
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Return mock user for debug mode
    return _createMockUser();
  }

  @override
  Future<UserModel> signInWithApple() async {
    // Return mock user for debug mode
    return _createMockUser();
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    // Return mock user for debug mode
    return _createMockUser();
  }

  @override
  Future<UserModel> signInAnonymously() async {
    // Return mock anonymous user for debug mode
    return _createMockAnonymousUser();
  }

  @override
  Future<void> signOut() async {
    // Do nothing in debug mode
    return;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Return null in debug mode (not signed in)
    return null;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Do nothing in debug mode
    return;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Do nothing in debug mode
    return;
  }

  @override
  Future<UserModel> updateProfile(String? name, String? photoUrl) async {
    // Return mock user for debug mode
    return _createMockUser();
  }

  @override
  Future<void> deleteAccount() async {
    // Do nothing in debug mode
    return;
  }

  @override
  Stream<UserModel?> watchAuthState() {
    // Return null stream in debug mode
    return Stream.value(null);
  }

  UserModel _createMockUser() {
    final now = DateTime.now();
    return UserModel(
      id: 'mock_user_id',
      email: 'mock@example.com',
      name: 'Mock User',
      role: UserRole.user,
      provider: AuthProvider.email,
      isEmailVerified: true,
      isPremium: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserModel _createMockAnonymousUser() {
    final now = DateTime.now();
    return UserModel(
      id: 'mock_anonymous_user_id',
      email: 'anonymous@mock.com',
      name: 'Usuário Anônimo',
      role: UserRole.user,
      provider: AuthProvider.anonymous,
      isEmailVerified: false,
      isPremium: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async {
    return Right(_createMockUser());
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    return Right(_createMockUser());
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return Right(_createMockUser());
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    return Right(_createMockUser());
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    return Right(_createMockUser());
  }

  @override
  Future<Either<Failure, User>> signInAnonymously() async {
    return Right(_createMockAnonymousUser());
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> updateProfile(
    String? name,
    String? photoUrl,
  ) async {
    return Right(_createMockUser());
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return const Right(null);
  }

  @override
  Stream<Either<Failure, User?>> watchAuthState() {
    return Stream.value(const Right(null));
  }

  User _createMockUser() {
    final now = DateTime.now();
    return User(
      id: 'mock_user_id',
      email: 'mock@example.com',
      name: 'Mock User',
      role: UserRole.user,
      provider: AuthProvider.email,
      isEmailVerified: true,
      isPremium: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  User _createMockAnonymousUser() {
    final now = DateTime.now();
    return User(
      id: 'mock_anonymous_user_id',
      email: 'anonymous@mock.com',
      name: 'Usuário Anônimo',
      role: UserRole.user,
      provider: AuthProvider.anonymous,
      isEmailVerified: false,
      isPremium: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

// Mock UseCase implementations
class _MockSignInWithEmail implements SignInWithEmail {
  @override
  Future<Either<Failure, User>> call(SignInWithEmailParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_user_id',
        email: params.email,
        name: 'Mock User',
        role: UserRole.user,
        provider: AuthProvider.email,
        isEmailVerified: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSignUpWithEmail implements SignUpWithEmail {
  @override
  Future<Either<Failure, User>> call(SignUpWithEmailParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_user_id',
        email: params.email,
        name: params.name ?? 'Mock User',
        role: UserRole.user,
        provider: AuthProvider.email,
        isEmailVerified: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSignInWithGoogle implements SignInWithGoogle {
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_user_id',
        email: 'mock.google@example.com',
        name: 'Mock Google User',
        role: UserRole.user,
        provider: AuthProvider.google,
        isEmailVerified: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSignInWithApple implements SignInWithApple {
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_user_id',
        email: 'mock.apple@example.com',
        name: 'Mock Apple User',
        role: UserRole.user,
        provider: AuthProvider.apple,
        isEmailVerified: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSignInWithFacebook implements SignInWithFacebook {
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_user_id',
        email: 'mock.facebook@example.com',
        name: 'Mock Facebook User',
        role: UserRole.user,
        provider: AuthProvider.facebook,
        isEmailVerified: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSignOut implements SignOut {
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return const Right(null);
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockGetCurrentUser implements GetCurrentUser {
  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return const Right(null);
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSendEmailVerification implements SendEmailVerification {
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return const Right(null);
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSendPasswordResetEmail implements SendPasswordResetEmail {
  @override
  Future<Either<Failure, void>> call(String email) async {
    return const Right(null);
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockUpdateProfile implements UpdateProfile {
  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_user_id',
        email: 'mock@example.com',
        name: params.name ?? 'Mock User',
        photoUrl: params.photoUrl,
        role: UserRole.user,
        provider: AuthProvider.email,
        isEmailVerified: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockDeleteAccount implements DeleteAccount {
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return const Right(null);
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

class _MockSignInAnonymously implements SignInAnonymously {
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    final now = DateTime.now();
    return Right(
      User(
        id: 'mock_anonymous_user_id',
        email: 'anonymous@mock.com',
        name: 'Usuário Anônimo',
        role: UserRole.user,
        provider: AuthProvider.anonymous,
        isEmailVerified: false,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  AuthRepository get repository => throw UnimplementedError();
}

/// Mock ReminderRemoteDataSource for web debug mode
class _MockReminderRemoteDataSource implements ReminderRemoteDataSource {
  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    // Return empty list in debug mode
    return [];
  }

  @override
  Future<List<ReminderModel>> getTodayReminders(String userId) async {
    // Return empty list in debug mode
    return [];
  }

  @override
  Future<List<ReminderModel>> getOverdueReminders(String userId) async {
    // Return empty list in debug mode
    return [];
  }

  @override
  Future<ReminderModel?> getReminderById(String id) async {
    // Return null in debug mode
    return null;
  }

  @override
  Future<String> addReminder(ReminderModel reminder, String userId) async {
    // Return fake ID in debug mode
    return 'mock_reminder_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    // Do nothing in debug mode
    return;
  }

  @override
  Future<void> deleteReminder(String id) async {
    // Do nothing in debug mode
    return;
  }

  @override
  Stream<List<ReminderModel>> streamReminders(String userId) {
    // Return empty stream in debug mode
    return Stream.value([]);
  }

  @override
  Stream<ReminderModel?> streamReminder(String id) {
    // Return null stream in debug mode
    return Stream.value(null);
  }
}

void _registerMockAppointmentsFeature() {
  // Mock Use Cases for web debug mode
  getIt.registerLazySingleton<GetAppointments>(() => _MockGetAppointments());

  getIt.registerLazySingleton<GetUpcomingAppointments>(
    () => _MockGetUpcomingAppointments(),
  );

  getIt.registerLazySingleton<GetAppointmentById>(
    () => _MockGetAppointmentById(),
  );

  getIt.registerLazySingleton<AddAppointment>(() => _MockAddAppointment());

  getIt.registerLazySingleton<UpdateAppointment>(
    () => _MockUpdateAppointment(),
  );

  getIt.registerLazySingleton<DeleteAppointment>(
    () => _MockDeleteAppointment(),
  );
}

void _registerMockVaccinesFeature() {
  // Mock Use Cases for web debug mode
  getIt.registerLazySingleton<GetVaccines>(() => _MockGetVaccines());
  getIt.registerLazySingleton<GetVaccineById>(() => _MockGetVaccineById());
  getIt.registerLazySingleton<GetVaccinesByAnimal>(
    () => _MockGetVaccinesByAnimal(),
  );
  getIt.registerLazySingleton<GetOverdueVaccines>(
    () => _MockGetOverdueVaccines(),
  );
  getIt.registerLazySingleton<GetUpcomingVaccines>(
    () => _MockGetUpcomingVaccines(),
  );
  getIt.registerLazySingleton<GetVaccineCalendar>(
    () => _MockGetVaccineCalendar(),
  );
  getIt.registerLazySingleton<GetVaccineStatistics>(
    () => _MockGetVaccineStatistics(),
  );
  getIt.registerLazySingleton<SearchVaccines>(() => _MockSearchVaccines());
  getIt.registerLazySingleton<AddVaccine>(() => _MockAddVaccine());
  getIt.registerLazySingleton<UpdateVaccine>(() => _MockUpdateVaccine());
  getIt.registerLazySingleton<DeleteVaccine>(() => _MockDeleteVaccine());
  getIt.registerLazySingleton<MarkVaccineCompleted>(
    () => _MockMarkVaccineCompleted(),
  );
  getIt.registerLazySingleton<ScheduleVaccineReminder>(
    () => _MockScheduleVaccineReminder(),
  );
}

// Mock Appointments Use Cases implementations
class _MockGetAppointments implements GetAppointments {
  @override
  final AppointmentRepository repository = _MockAppointmentRepository();

  @override
  Future<Either<Failure, List<Appointment>>> call(
    GetAppointmentsParams params,
  ) async {
    return const Right([]);
  }
}

class _MockGetUpcomingAppointments implements GetUpcomingAppointments {
  @override
  final AppointmentRepository repository = _MockAppointmentRepository();

  @override
  Future<Either<Failure, List<Appointment>>> call(
    GetUpcomingAppointmentsParams params,
  ) async {
    return const Right([]);
  }
}

class _MockGetAppointmentById implements GetAppointmentById {
  @override
  final AppointmentRepository repository = _MockAppointmentRepository();

  @override
  Future<Either<Failure, Appointment?>> call(
    GetAppointmentByIdParams params,
  ) async {
    return const Right(null);
  }
}

class _MockAddAppointment implements AddAppointment {
  @override
  final AppointmentRepository repository = _MockAppointmentRepository();

  @override
  Future<Either<Failure, Appointment>> call(AddAppointmentParams params) async {
    return Right(params.appointment);
  }
}

class _MockUpdateAppointment implements UpdateAppointment {
  @override
  final AppointmentRepository repository = _MockAppointmentRepository();

  @override
  Future<Either<Failure, Appointment>> call(
    UpdateAppointmentParams params,
  ) async {
    return Right(params.appointment);
  }
}

class _MockDeleteAppointment implements DeleteAppointment {
  @override
  final AppointmentRepository repository = _MockAppointmentRepository();

  @override
  Future<Either<Failure, void>> call(DeleteAppointmentParams params) async {
    return const Right(null);
  }
}

class _MockAppointmentRepository implements AppointmentRepository {
  @override
  Future<Either<Failure, List<Appointment>>> getAppointments(
    String animalId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(
    String animalId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Appointment?>> getAppointmentById(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Appointment>> addAppointment(
    Appointment appointment,
  ) async {
    return Right(appointment);
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment(
    Appointment appointment,
  ) async {
    return Right(appointment);
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return const Right([]);
  }
}

// Mock Vaccines Use Cases implementations
class _MockGetVaccines implements GetVaccines {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, List<Vaccine>>> call(GetVaccinesParams params) async {
    return const Right([]);
  }
}

class _MockAddVaccine implements AddVaccine {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Vaccine>> call(Vaccine vaccine) async {
    return Right(vaccine);
  }
}

class _MockVaccineRepository implements VaccineRepository {
  @override
  Future<Either<Failure, List<Vaccine>>> getVaccines() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByAnimal(
    String animalId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Vaccine?>> getVaccineById(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Vaccine>> addVaccine(Vaccine vaccine) async {
    return Right(vaccine);
  }

  @override
  Future<Either<Failure, Vaccine>> updateVaccine(Vaccine vaccine) async {
    return Right(vaccine);
  }

  @override
  Future<Either<Failure, void>> deleteVaccine(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteVaccinesByAnimal(String animalId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getPendingVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getOverdueVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getCompletedVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getRequiredVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getUpcomingVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getDueTodayVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getDueSoonVaccines([
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByMonth(
    int year,
    int month, [
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Map<DateTime, List<Vaccine>>>> getVaccineCalendar(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesNeedingReminders() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>>
  getVaccinesWithActiveReminders() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Vaccine>> scheduleVaccineReminder(
    String vaccineId,
    DateTime reminderDate,
  ) async {
    final now = DateTime.now();
    final mockVaccine = Vaccine(
      id: vaccineId,
      animalId: 'mock_animal',
      name: 'Mock Vaccine',
      veterinarian: 'Mock Vet',
      date: now,
      reminderDate: reminderDate,
      createdAt: now,
      updatedAt: now,
    );
    return Right(mockVaccine);
  }

  @override
  Future<Either<Failure, void>> removeVaccineReminder(String vaccineId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> searchVaccines(
    String query, [
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByVeterinarian(
    String veterinarian, [
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByName(
    String vaccineName, [
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByManufacturer(
    String manufacturer, [
    String? animalId,
  ]) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getVaccineStatistics([
    String? animalId,
  ]) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccineHistory(
    String animalId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Map<String, List<Vaccine>>>> getVaccinesByStatus([
    String? animalId,
  ]) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, List<String>>> getVaccineNames() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getVeterinarians() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getManufacturers() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Vaccine>>> addMultipleVaccines(
    List<Vaccine> vaccines,
  ) async {
    return Right(vaccines);
  }

  @override
  Future<Either<Failure, void>> markVaccinesAsCompleted(
    List<String> vaccineIds,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateVaccineStatuses(
    List<String> vaccineIds,
    VaccineStatus status,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> syncVaccines() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportVaccineData([
    String? animalId,
  ]) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, void>> importVaccineData(
    Map<String, dynamic> data,
  ) async {
    return const Right(null);
  }
}

// Additional Mock Vaccine Use Cases
class _MockGetVaccineById implements GetVaccineById {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Vaccine?>> call(String vaccineId) async {
    return const Right(null);
  }
}

class _MockGetVaccinesByAnimal implements GetVaccinesByAnimal {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, List<Vaccine>>> call(String animalId) async {
    return const Right([]);
  }
}

class _MockGetOverdueVaccines implements GetOverdueVaccines {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, List<Vaccine>>> call(
    GetOverdueVaccinesParams params,
  ) async {
    return const Right([]);
  }
}

class _MockGetUpcomingVaccines implements GetUpcomingVaccines {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, List<Vaccine>>> call(
    GetUpcomingVaccinesParams params,
  ) async {
    return const Right([]);
  }
}

class _MockGetVaccineCalendar implements GetVaccineCalendar {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Map<DateTime, List<Vaccine>>>> call(
    GetVaccineCalendarParams params,
  ) async {
    return const Right({});
  }
}

class _MockGetVaccineStatistics implements GetVaccineStatistics {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Map<String, int>>> call(
    GetVaccineStatisticsParams params,
  ) async {
    return const Right({});
  }
}

class _MockSearchVaccines implements SearchVaccines {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, List<Vaccine>>> call(
    SearchVaccinesParams params,
  ) async {
    return const Right([]);
  }
}

class _MockUpdateVaccine implements UpdateVaccine {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Vaccine>> call(Vaccine vaccine) async {
    return Right(vaccine);
  }
}

class _MockDeleteVaccine implements DeleteVaccine {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, void>> call(String vaccineId) async {
    return const Right(null);
  }
}

class _MockMarkVaccineCompleted implements MarkVaccineCompleted {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Vaccine>> call(String vaccineId) async {
    final now = DateTime.now();
    final mockVaccine = Vaccine(
      id: vaccineId,
      animalId: 'mock_animal',
      name: 'Mock Vaccine',
      veterinarian: 'Mock Vet',
      date: now,
      isCompleted: true,
      createdAt: now,
      updatedAt: now,
    );
    return Right(mockVaccine);
  }
}

class _MockScheduleVaccineReminder implements ScheduleVaccineReminder {
  @override
  final VaccineRepository repository = _MockVaccineRepository();

  @override
  Future<Either<Failure, Vaccine>> call(
    ScheduleVaccineReminderParams params,
  ) async {
    final now = DateTime.now();
    final mockVaccine = Vaccine(
      id: params.vaccineId,
      animalId: 'mock_animal',
      name: 'Mock Vaccine',
      veterinarian: 'Mock Vet',
      date: now,
      reminderDate: params.reminderDate,
      createdAt: now,
      updatedAt: now,
    );
    return Right(mockVaccine);
  }
}
