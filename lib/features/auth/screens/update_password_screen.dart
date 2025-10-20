import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/password_field.dart';
import 'login_screen.dart';

/// Update password screen for password reset
///
/// Features:
/// - New password and confirmation fields
/// - Form validation (password strength, password match)
/// - Updates user password after password reset
/// - Navigation to login after successful update
/// - Handles deep linking from password reset email
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  /// Handles password update
  void _handleUpdatePassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      PasswordUpdateRequested(password: _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Show success message and navigate to login
        if (state is PasswordUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hasło zostało zmienione pomyślnie'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
        // Show error messages
        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nowe hasło'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
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
                      // Icon
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        'Ustaw nowe hasło',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        'Wprowadź nowe hasło dla swojego konta',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // New password field
                      PasswordField(
                        controller: _passwordController,
                        label: 'Nowe hasło',
                        hintText: 'Min. 8 znaków',
                        validator: _validatePassword,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Confirm password field
                      PasswordField(
                        controller: _confirmPasswordController,
                        label: 'Powtórz nowe hasło',
                        validator: _validateConfirmPassword,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 8),

                      // Password requirements info
                      Card(
                        color: colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Wymagania dotyczące hasła:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Minimum 8 znaków',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Update password button
                      FilledButton(
                        onPressed: isLoading ? null : _handleUpdatePassword,
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
                            : const Text('Zaktualizuj hasło'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
