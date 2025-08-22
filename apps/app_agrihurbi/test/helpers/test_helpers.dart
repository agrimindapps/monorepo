import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';

/// Test helpers for AgriHurbi app
class TestHelpers {
  /// Create a material app wrapper for testing widgets
  static Widget createApp({
    required Widget child,
    List<ChangeNotifierProvider>? providers,
    ThemeData? theme,
  }) {
    return MultiProvider(
      providers: providers ?? [],
      child: MaterialApp(
        theme: theme,
        home: child,
      ),
    );
  }

  /// Create app with router for navigation testing
  static Widget createAppWithRouter({
    required Widget child,
    List<ChangeNotifierProvider>? providers,
  }) {
    return MultiProvider(
      providers: providers ?? [],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// Create mock providers for testing
  static List<ChangeNotifierProvider> createMockProviders({
    AuthProvider? mockAuthProvider,
  }) {
    return [
      if (mockAuthProvider != null)
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
    ];
  }

  /// Setup GetIt for testing
  static void setupTestGetIt() {
    if (GetIt.instance.isRegistered<AuthProvider>()) {
      GetIt.instance.unregister<AuthProvider>();
    }
    
    // Register mock dependencies as needed
    // GetIt.instance.registerSingleton<AuthProvider>(mockAuthProvider);
  }

  /// Reset GetIt after tests
  static void resetTestGetIt() {
    GetIt.instance.reset();
  }

  /// Find widget by key
  static Finder findByKey(String key) => find.byKey(Key(key));

  /// Find widget by text
  static Finder findByText(String text) => find.text(text);

  /// Find widget by type
  static Finder findByType<T>() => find.byType(T);

  /// Wait for animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Tap widget and wait
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration? timeout,
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(timeout ?? const Duration(seconds: 1));
  }

  /// Enter text in field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verify snackbar is shown
  static void verifySnackbar(WidgetTester tester, String message) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }

  /// Verify dialog is shown
  static void verifyDialog(String title) {
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(title), findsOneWidget);
  }

  /// Mock user data
  static Map<String, dynamic> createMockUserData({
    String id = '123',
    String email = 'test@test.com',
    String displayName = 'Test User',
    String? photoUrl,
    bool isEmailVerified = true,
  }) {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Mock failure response
  static Exception createMockFailure(String message) {
    return Exception(message);
  }

  /// Create test theme
  static ThemeData get testTheme => ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}

/// Base class for widget tests
abstract class BaseWidgetTest {
  late Widget testWidget;
  List<ChangeNotifierProvider>? providers;

  /// Setup method to be overridden by subclasses
  void setUp();

  /// Teardown method
  void tearDown() {
    TestHelpers.resetTestGetIt();
  }

  /// Create the widget under test
  Widget createWidget() {
    return TestHelpers.createApp(
      child: testWidget,
      providers: providers,
      theme: TestHelpers.testTheme,
    );
  }
}

/// Mixin for auth-related tests
mixin AuthTestMixin {
  late MockAuthProvider mockAuthProvider;

  void setUpAuthMocks() {
    mockAuthProvider = MockAuthProvider();
  }

  void configureAuthMocks({
    bool isLoggedIn = false,
    bool isLoading = false,
    String? errorMessage,
  }) {
    when(mockAuthProvider.isLoggedIn).thenReturn(isLoggedIn);
    when(mockAuthProvider.isLoading).thenReturn(isLoading);
    when(mockAuthProvider.errorMessage).thenReturn(errorMessage);
  }
}

/// Mock classes for testing
class MockAuthProvider extends Mock implements AuthProvider {}

/// Test constants
class TestConstants {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testName = 'Test User';
  static const String testPhone = '(11) 99999-9999';
  
  static const Duration defaultTimeout = Duration(seconds: 5);
  static const Duration shortTimeout = Duration(milliseconds: 500);
}

/// Test utilities for specific features
class AuthTestUtils {
  /// Fill login form
  static Future<void> fillLoginForm(
    WidgetTester tester, {
    String email = TestConstants.testEmail,
    String password = TestConstants.testPassword,
  }) async {
    await TestHelpers.enterText(
      tester,
      find.byType(TextFormField).first,
      email,
    );
    
    await TestHelpers.enterText(
      tester,
      find.byType(TextFormField).at(1),
      password,
    );
  }

  /// Fill register form
  static Future<void> fillRegisterForm(
    WidgetTester tester, {
    String name = TestConstants.testName,
    String email = TestConstants.testEmail,
    String password = TestConstants.testPassword,
    String? phone,
  }) async {
    final textFields = find.byType(TextFormField);
    
    await TestHelpers.enterText(tester, textFields.at(0), name);
    await TestHelpers.enterText(tester, textFields.at(1), email);
    
    if (phone != null) {
      await TestHelpers.enterText(tester, textFields.at(2), phone);
    }
    
    await TestHelpers.enterText(tester, textFields.at(3), password);
    await TestHelpers.enterText(tester, textFields.at(4), password);
  }

  /// Submit form
  static Future<void> submitForm(WidgetTester tester) async {
    final submitButton = find.byType(ElevatedButton);
    expect(submitButton, findsOneWidget);
    
    await TestHelpers.tapAndWait(tester, submitButton);
  }
}

/// Mock data generators
class MockDataGenerators {
  static Map<String, dynamic> generateUserData({
    String? id,
    String? email,
    String? displayName,
  }) {
    return TestHelpers.createMockUserData(
      id: id ?? 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email ?? 'mock${DateTime.now().millisecondsSinceEpoch}@test.com',
      displayName: displayName ?? 'Mock User ${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}