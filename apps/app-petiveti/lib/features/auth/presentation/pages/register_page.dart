import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/register_page_coordinator.dart';
import '../widgets/register_page_header.dart';
import '../widgets/register_form_fields.dart';
import '../widgets/register_social_auth.dart';

/// **User Registration Page - Secure Authentication Interface**
/// 
/// A comprehensive registration page that provides secure user onboarding
/// with form validation, error handling, and responsive design.
/// 
/// ## Key Features:
/// - **Form Validation**: Real-time validation with user-friendly error messages
/// - **Password Security**: Secure password input with visibility toggles
/// - **Terms Acceptance**: Required terms and conditions acknowledgment
/// - **Social Authentication**: Integration with Google and Apple Sign-In
/// - **Responsive Design**: Adapts to different screen sizes and orientations
/// - **Accessibility**: Full semantic support for screen readers
/// 
/// ## Widget Architecture:
/// 
/// ### **Form Structure:**
/// ```
/// RegisterPage
/// ├── AppBar (with back navigation)
/// ├── SingleChildScrollView
///     ├── Registration Header
///     ├── Form Fields Container
///     │   ├── Name Input Field
///     │   ├── Email Input Field  
///     │   ├── Password Input Field (with visibility toggle)
///     │   ├── Confirm Password Field (with visibility toggle)
///     │   └── Terms & Conditions Checkbox
///     ├── Registration Button
///     ├── Social Authentication Buttons
///     │   ├── Google Sign-In Button
///     │   └── Apple Sign-In Button (iOS only)
///     └── Login Navigation Link
/// ```
/// 
/// ## State Management:
/// 
/// ### **Form Controllers:**
/// - **_nameController**: Manages user's full name input
/// - **_emailController**: Handles email address with validation
/// - **_passwordController**: Secure password input management
/// - **_confirmPasswordController**: Password confirmation matching
/// 
/// ### **UI State Variables:**
/// - **_obscurePassword**: Controls password visibility toggle
/// - **_obscureConfirmPassword**: Controls confirm password visibility
/// - **_acceptedTerms**: Tracks terms and conditions acceptance
/// - **_formKey**: Global form validation state management
/// 
/// ## Validation Logic:
/// 
/// ### **Name Validation:**
/// - Required field (non-empty)
/// - Minimum 2 characters
/// - Only alphabetic characters and spaces
/// - Trims whitespace automatically
/// 
/// ### **Email Validation:**
/// - Required field (non-empty)  
/// - Valid email format using RegExp
/// - Converts to lowercase automatically
/// - Checks for common email pattern mismatches
/// 
/// ### **Password Validation:**
/// - Minimum 8 characters length
/// - Must contain at least one uppercase letter
/// - Must contain at least one lowercase letter
/// - Must contain at least one numeric digit
/// - Must contain at least one special character
/// - Real-time strength indicator (future enhancement)
/// 
/// ### **Confirm Password Validation:**
/// - Must exactly match the password field
/// - Real-time matching feedback
/// - Updates dynamically as user types
/// 
/// ## Widget Functionality:
/// 
/// ### **Password Visibility Toggles:**
/// Custom IconButton widgets that toggle password field visibility
/// while maintaining secure input handling and accessibility labels.
/// 
/// ### **Terms & Conditions Checkbox:**
/// Required checkbox with link to terms document. Prevents registration
/// submission until explicitly accepted by the user.
/// 
/// ### **Social Authentication Integration:**
/// - **Google Sign-In**: Uses official Google Sign-In SDK
/// - **Apple Sign-In**: Platform-specific implementation for iOS
/// - **Error Handling**: Graceful fallback for authentication failures
/// 
/// ### **Responsive Button Layout:**
/// Registration and social authentication buttons adapt to screen size
/// using Flexible and Expanded widgets for optimal user experience.
/// 
/// ## Navigation Flow:
/// - **Successful Registration**: Navigates to home page (`/`)
/// - **Social Auth Success**: Direct navigation to main app
/// - **Back Navigation**: Returns to previous page or login
/// - **Login Link**: Navigates to login page for existing users
/// 
/// ## Error Handling:
/// - **Network Errors**: User-friendly network connectivity messages
/// - **Authentication Errors**: Clear feedback for auth failures
/// - **Validation Errors**: Real-time form validation feedback
/// - **Loading States**: Visual indicators during registration process
/// 
/// ## Accessibility Features:
/// - **Semantic Labels**: All form fields have appropriate labels
/// - **Screen Reader Support**: Complete voice-over navigation
/// - **Keyboard Navigation**: Full keyboard accessibility
/// - **Focus Management**: Logical tab order through form fields
/// - **High Contrast**: Supports accessibility color themes
/// 
/// ## Performance Optimizations:
/// - **Controller Disposal**: Proper memory management in dispose()
/// - **Form State Management**: Efficient form validation caching
/// - **Responsive Rebuilds**: Minimal widget rebuilds during validation
/// - **Image Optimization**: Efficient social button icons
/// 
/// ## Security Considerations:
/// - **Password Masking**: Secure password input by default
/// - **Input Sanitization**: Automatic trimming and validation
/// - **HTTPS Communication**: All auth requests use secure connections
/// - **Token Management**: Secure storage of authentication tokens
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced validation and social authentication
class RegisterPage extends ConsumerStatefulWidget {
  /// Creates a user registration page.
  /// 
  /// This page provides a complete user onboarding experience with
  /// form validation, social authentication options, and secure
  /// password handling.
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Setup authentication state listener
    RegisterPageCoordinator.setupAuthListener(ref: ref, context: context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RegisterPageHeader(),
                RegisterFormFields(
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  acceptedTerms: _acceptedTerms,
                  onTermsChanged: (value) => setState(() => _acceptedTerms = value),
                ),
                const SizedBox(height: 24),
                _buildRegisterButton(authState),
                const SizedBox(height: 16),
                _buildLoginLink(),
                const SizedBox(height: 32),
                const RegisterSocialAuth(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Register Button Widget**
  /// 
  /// Main registration button with loading state and validation.
  Widget _buildRegisterButton(AuthState authState) {
    return ElevatedButton(
      onPressed: (authState.isLoading || !_acceptedTerms) 
          ? null 
          : () => _handleRegister(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: authState.isLoading
          ? const CircularProgressIndicator()
          : const Text('Criar Conta'),
    );
  }

  /// **Login Link Widget**
  /// 
  /// Link for existing users to navigate back to login page.
  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => RegisterPageCoordinator.navigateToLogin(context),
      child: const Text('Já tem uma conta? Faça login'),
    );
  }

  /// **Handle Registration Form Submission**
  /// 
  /// Processes registration form using the coordinator.
  Future<void> _handleRegister() async {
    if (!RegisterPageCoordinator.validateRegistrationForm(
      formKey: _formKey,
      termsAccepted: _acceptedTerms,
    )) {
      return;
    }

    await RegisterPageCoordinator.handleRegistration(
      ref: ref,
      context: context,
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      termsAccepted: _acceptedTerms,
    );
  }
}