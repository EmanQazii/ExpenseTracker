import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../contollers/auth_controller.dart';
import 'package:gotrue/gotrue.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = AuthController();
  bool loading = false;

  Future<void> _signup() async {
    setState(() => loading = true);

    try {
      final response = await authController.signup(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      if (response?.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signup successful!')));
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Try again.')),
        );
      }
    } catch (e) {
      setState(() => loading = false);

      String errorMessage = e.toString();

      if (errorMessage.contains('already registered') ||
          errorMessage.contains('User already registered')) {
        errorMessage = 'This email is already in use. Please login instead.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 24)),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _signup,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Sign Up"),
            ),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
