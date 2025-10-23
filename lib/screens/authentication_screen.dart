import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../features/auth/view/login_screen.dart';

/// AuthenticationScreen - wrapper for authentication flow
///
/// This screen serves as an entry point to the authentication flow,
/// displaying the LoginScreen which handles navigation to other auth screens.
class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  static final Logger _logger = Logger('AuthenticationScreen');

  @override
  Widget build(BuildContext context) {
    _logger.fine('Building authentication screen');
    return const LoginScreen();
  }
}
