import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Login screen for user authentication
///
/// Features:
/// - Email and password input fields
/// - Form validation
/// - Navigation to registration and password reset
/// - Loading state handling
/// - Error feedback via SnackBar
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  /// Validates password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste';
    }
    return null;
  }

  /// Handles login action
  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      SignInRequested(
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
        print('🔍 LoginScreen - State changed to: ${state.runtimeType}');
        if (state is AuthError) {
          print('🔍 LoginScreen - AuthError message: ${state.message}');
        }

        // Show success message when confirmation email is resent
        if (state is ConfirmationEmailResent) {
          print('✅ LoginScreen - Showing confirmation email resent message');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email weryfikacyjny został wysłany ponownie. Sprawdź swoją skrzynkę pocztową.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
        // Show error messages with option to resend confirmation
        else if (state is AuthError) {
          print('❌ LoginScreen - Showing error SnackBar');
          final isEmailNotConfirmed =
              state.message.toLowerCase().contains('nie został potwierdzony') ||
              state.message.toLowerCase().contains('not confirmed');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
              duration: isEmailNotConfirmed
                  ? const Duration(seconds: 7)
                  : const Duration(seconds: 4),
              action: isEmailNotConfirmed
                  ? SnackBarAction(
                      label: 'Wyślij ponownie',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          ConfirmationEmailResendRequested(
                            email: _emailController.text.trim(),
                          ),
                        );
                      },
                    )
                  : null,
            ),
          );
        }
        // Navigation is handled by AuthGate via BlocBuilder
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            appBar: AppBar(title: const Text('Logowanie'), centerTitle: true),
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
                          'Witaj ponownie!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Zaloguj się do swojego konta',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Email field
                        AuthTextField(
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
                          controller: _passwordController,
                          label: 'Hasło',
                          validator: _validatePassword,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 8),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('Zapomniałeś hasła?'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        FilledButton(
                          onPressed: isLoading ? null : _handleLogin,
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
                              : const Text('Zaloguj się'),
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

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nie masz konta? ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                              child: const Text('Zarejestruj się'),
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
