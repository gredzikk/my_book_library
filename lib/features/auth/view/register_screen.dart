import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import 'login_screen.dart';
import '../../../widgets/auth_gate.dart';

/// Registration screen for new users
///
/// Features:
/// - Email, password and password confirmation fields
/// - Form validation (email format, password strength, password match)
/// - Loading state handling
/// - Success message with email verification notice
/// - Navigation to login screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste';
    }

    // Basic email regex validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Wprowadź poprawny adres e-mail';
    }

    return null;
  }

  /// Validates password strength
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste';
    }

    if (value.length < 8) {
      return 'Hasło musi mieć co najmniej 8 znaków';
    }

    return null;
  }

  /// Validates password confirmation
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste';
    }

    if (value != _passwordController.text) {
      return 'Hasła nie są zgodne';
    }

    return null;
  }

  /// Handles registration action
  void _handleRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Debug logging
        print('📝 RegisterScreen - State changed to: ${state.runtimeType}');
        if (state is AuthError) {
          print('📝 RegisterScreen - AuthError message: ${state.message}');
        }

        // Show success message when registration succeeds
        if (state is SignUpSuccess) {
          print('✅ RegisterScreen - SignUpSuccess');

          // Wait a moment to check if user gets auto-authenticated
          // This happens in test environment with email auto-confirmation
          Future.delayed(const Duration(milliseconds: 500), () {
            // Check if we're still mounted and not already authenticated
            if (!context.mounted) return;

            final currentState = context.read<AuthBloc>().state;
            if (currentState is Authenticated) {
              print(
                '📝 RegisterScreen - User already authenticated, removing auth routes',
              );
              // User is already authenticated, remove all auth routes to reveal home screen
              // Use pushAndRemoveUntil to clear the navigation stack and go back to AuthGate
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            } else {
              print(
                '📝 RegisterScreen - User needs email confirmation, navigating to login',
              );
              // User needs to confirm email, navigate to login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Sprawdź swoją skrzynkę pocztową, aby dokończyć rejestrację.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 5),
                ),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          });
        }
        // Show error messages
        else if (state is AuthError) {
          print('❌ RegisterScreen - Showing error SnackBar');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            appBar: AppBar(title: const Text('Rejestracja'), centerTitle: true),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App icon/logo
                        Icon(
                          Icons.library_books,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),

                        // Welcome text
                        Text(
                          'Utwórz konto',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dołącz do naszej społeczności czytelników',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Email field
                        AuthTextField(
                          key: const Key('register_email_field'),
                          controller: _emailController,
                          label: 'Adres e-mail',
                          hintText: 'twoj@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          enabled: !isLoading,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        PasswordField(
                          key: const Key('register_password_field'),
                          controller: _passwordController,
                          label: 'Hasło',
                          hintText: 'Min. 8 znaków',
                          validator: _validatePassword,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Confirm password field
                        PasswordField(
                          key: const Key('register_confirm_password_field'),
                          controller: _confirmPasswordController,
                          label: 'Powtórz hasło',
                          validator: _validateConfirmPassword,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 32),

                        // Register button
                        FilledButton(
                          key: const Key('register_submit_button'),
                          onPressed: isLoading ? null : _handleRegister,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Zarejestruj się'),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: colorScheme.outline),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'lub',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: colorScheme.outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Masz już konto? ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              key: const Key('register_to_login_button'),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                              child: const Text('Zaloguj się'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
