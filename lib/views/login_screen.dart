import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: _authController.isLoading.value ? null : () => _signIn(context),
                  child: _authController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _signInWithGoogle(context),
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  label: const Text('Sign in with Google'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) async {
    debugPrint('Attempting to sign in...');
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        debugPrint('Sign in failed: Empty fields');
        Get.snackbar(
          'Error',
          'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      debugPrint('Calling AuthController.signIn...');
      await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      debugPrint('Sign in completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Sign in error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    debugPrint('Attempting Google sign in...');
    try {
      await _authController.signInWithGoogle();
      debugPrint('Google sign in completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Google sign in error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    debugPrint('Showing forgot password dialog...');
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('Forgot password dialog cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                debugPrint('Attempting to send password reset email...');
                try {
                  await _authController.resetPassword(emailController.text.trim());
                  debugPrint('Password reset email sent successfully');
                  Navigator.pop(context);
                } catch (e, stackTrace) {
                  debugPrint('Password reset error: $e');
                  debugPrint('Stack trace: $stackTrace');
                }
              } else {
                debugPrint('Password reset failed: Empty email');
                Get.snackbar(
                  'Error',
                  'Please enter your email address',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
