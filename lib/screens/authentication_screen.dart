import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';

/// AuthenticationScreen - wrapper for authentication flow
///
/// This screen serves as an entry point to the authentication flow,
/// displaying the LoginScreen which handles navigation to other auth screens.
class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
