import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/auth_text_field.dart';

/// Forgot password screen for password reset requests
///
/// Features:
/// - Email input field
/// - Form validation
/// - Sends password reset email
/// - Success feedback
/// - Back navigation to login
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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

  /// Handles password reset request
  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      PasswordResetRequested(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Show error messages
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final emailSent = state is PasswordResetEmailSent;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Resetowanie hasła'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: emailSent
                      ? _buildSuccessView(context, state)
                      : _buildForm(context, isLoading),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the password reset form
  Widget _buildForm(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Icon(Icons.lock_reset, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),

          // Title
          Text(
            'Zapomniałeś hasła?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'Wprowadź swój adres e-mail, a wyślemy Ci link do zresetowania hasła.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
          const SizedBox(height: 32),

          // Send reset link button
          FilledButton(
            onPressed: isLoading ? null : _handleResetPassword,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Wyślij link resetujący'),
          ),
          const SizedBox(height: 16),

          // Back to login button
          OutlinedButton(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Powrót do logowania'),
          ),
        ],
      ),
    );
  }

  /// Builds the success view after email is sent
  Widget _buildSuccessView(BuildContext context, AuthState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final email = (state as PasswordResetEmailSent).email;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Icon(Icons.mark_email_read, size: 80, color: Colors.green),
        const SizedBox(height: 16),

        // Success message
        Text(
          'E-mail został wysłany!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Instructions
        Text(
          'Instrukcje resetowania hasła zostały wysłane na adres:\n$email',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Additional info
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'Sprawdź swoją skrzynkę pocztową (w tym folder spam) i kliknij link, aby zresetować hasło.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Back to login button
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Powrót do logowania'),
        ),
      ],
    );
  }
}
