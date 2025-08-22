import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Core Storage
import '../storage/hive_service.dart';
import '../notifications/notification_service.dart';
import '../cache/cache_service.dart';
import '../performance/performance_service.dart';
import '../optimization/lazy_loader.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';

// Features - Animals
import '../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../features/animals/data/datasources/animal_remote_datasource.dart';
import '../../features/animals/data/repositories/animal_repository_hybrid_impl.dart';
import '../../features/animals/domain/repositories/animal_repository.dart';
import '../../features/animals/domain/usecases/get_animals.dart';
import '../../features/animals/domain/usecases/get_animal_by_id.dart';
import '../../features/animals/domain/usecases/add_animal.dart';
import '../../features/animals/domain/usecases/update_animal.dart';
import '../../features/animals/domain/usecases/delete_animal.dart';

// Features - Appointments
import '../../features/appointments/data/datasources/appointment_local_datasource.dart';
import '../../features/appointments/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/get_appointments.dart';
import '../../features/appointments/domain/usecases/get_upcoming_appointments.dart';
import '../../features/appointments/domain/usecases/get_appointment_by_id.dart';
import '../../features/appointments/domain/usecases/add_appointment.dart';
import '../../features/appointments/domain/usecases/update_appointment.dart';
import '../../features/appointments/domain/usecases/delete_appointment.dart';

// Features - Vaccines  
import '../../features/vaccines/data/datasources/vaccine_local_datasource.dart';
import '../../features/vaccines/data/repositories/vaccine_repository_impl.dart';
import '../../features/vaccines/domain/repositories/vaccine_repository.dart';
import '../../features/vaccines/domain/usecases/get_vaccines.dart';
import '../../features/vaccines/domain/usecases/add_vaccine.dart';

// Features - Medications
import '../../features/medications/data/datasources/medication_local_datasource.dart';
import '../../features/medications/data/repositories/medication_repository_local_only_impl.dart';
import '../../features/medications/domain/repositories/medication_repository.dart';
import '../../features/medications/domain/usecases/get_medications.dart';
import '../../features/medications/domain/usecases/get_medications_by_animal_id.dart';
import '../../features/medications/domain/usecases/get_active_medications.dart';
import '../../features/medications/domain/usecases/add_medication.dart';
import '../../features/medications/domain/usecases/update_medication.dart';
import '../../features/medications/domain/usecases/delete_medication.dart' show DeleteMedication, DiscontinueMedication;
import '../../features/medications/domain/usecases/get_medication_by_id.dart';
import '../../features/medications/domain/usecases/get_expiring_medications.dart';

// Features - Weight
import '../../features/weight/data/datasources/weight_local_datasource.dart';
import '../../features/weight/data/repositories/weight_repository_impl.dart';
import '../../features/weight/domain/repositories/weight_repository.dart';
import '../../features/weight/domain/usecases/get_weights.dart';

// Features - Reminders
import '../../features/reminders/data/datasources/reminder_local_datasource.dart';
import '../../features/reminders/data/datasources/reminder_remote_datasource.dart';
import '../../features/reminders/data/repositories/reminder_repository_hybrid_impl.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/domain/usecases/get_reminders.dart';
import '../../features/reminders/domain/usecases/add_reminder.dart';
import '../../features/reminders/domain/usecases/update_reminder.dart';
import '../../features/reminders/domain/usecases/delete_reminder.dart';

// Features - Expenses
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_hybrid_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/expense_usecases.dart';
import '../../features/weight/domain/usecases/get_weights_by_animal_id.dart';
import '../../features/weight/domain/usecases/add_weight.dart';
import '../../features/weight/domain/usecases/get_weight_statistics.dart';
import '../../features/weight/domain/usecases/update_weight.dart';

// Features - Subscription
import '../../features/subscription/data/datasources/subscription_local_datasource.dart';
import '../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/domain/usecases/subscription_usecases.dart';

// Features - Calculators
import '../../features/calculators/domain/strategies/body_condition_strategy.dart';

// Core Auth Services
import '../auth/auth_service.dart';

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
  
  // Features services
  _registerAuthFeature();
  _registerSubscriptionFeature();
  _registerAnimalsFeature();
  _registerAppointmentsFeature();
  _registerVaccinesFeature();
  _registerMedicationsFeature();
  _registerWeightFeature();
  _registerRemindersFeature();
  _registerExpensesFeature();
  _registerCalculatorsFeature();

  // Core services that depend on features
  _registerCoreAuthServices();
}

void _registerExternalServices() {
  // Connectivity
  getIt.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );
  
  // Firebase Auth
  getIt.registerLazySingleton<firebase_auth.FirebaseAuth>(
    () => firebase_auth.FirebaseAuth.instance,
  );
  
  // Firebase Firestore
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Google Sign In
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(),
  );

  // RevenueCat Purchases
  getIt.registerLazySingleton<Purchases>(
    () => Purchases,
  );
}

void _registerCoreServices() {
  // Hive Service
  getIt.registerLazySingleton<HiveService>(
    () => HiveService.instance,
  );
  
  // Notification Service
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );
  
  // Cache Service
  getIt.registerLazySingleton<CacheService>(
    () => CacheService(),
  );
  
  // Performance Service
  getIt.registerLazySingleton<PerformanceService>(
    () => PerformanceService(),
  );
  
  // Lazy Loader
  getIt.registerLazySingleton<LazyLoader>(
    () => LazyLoader(),
  );
}

void _registerAuthFeature() {
  // Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<firebase_auth.FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
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
  
  // Use Cases
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

void _registerAnimalsFeature() {
  // Data Sources
  getIt.registerLazySingleton<AnimalLocalDataSource>(
    () => AnimalLocalDataSourceImpl(getIt<HiveService>()),
  );
  
  getIt.registerLazySingleton<AnimalRemoteDataSource>(
    () => AnimalRemoteDataSourceImpl(),
  );
  
  // Repository (hybrid with local + remote sync)
  getIt.registerLazySingleton<AnimalRepository>(
    () => AnimalRepositoryHybridImpl(
      localDataSource: getIt<AnimalLocalDataSource>(),
      remoteDataSource: getIt<AnimalRemoteDataSource>(),
      connectivity: getIt<Connectivity>(),
    ),
  );
  
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
    () => VaccineLocalDataSourceImpl(),
  );
  
  // Repository (local-only for now, can be upgraded to hybrid later)
  getIt.registerLazySingleton<VaccineRepository>(
    () => VaccineRepositoryImpl(
      localDataSource: getIt<VaccineLocalDataSource>(),
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
    () => WeightRepositoryImpl(
      localDataSource: getIt<WeightLocalDataSource>(),
    ),
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
  
  getIt.registerLazySingleton<ReminderRemoteDataSource>(
    () => ReminderRemoteDataSourceImpl(),
  );
  
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
      revenuecat: getIt<Purchases>(),
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
  // Strategies
  getIt.registerLazySingleton<BodyConditionStrategy>(
    () => const BodyConditionStrategy(),
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