import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../contollers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final authController = AuthController();
  bool loading = false;

  Future<void> _resetPassword() async {
    setState(() => loading = true);

    try {
      await authController.resetPassword(emailController.text.trim());
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
        ),
      );
      context.go('/');
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your email to receive a password reset link",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _resetPassword,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
