import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../contollers/auth_controller.dart';
import '../../../services/user_service.dart';

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
  bool _obscurePassword = true;

  Future<void> _signup() async {
    setState(() => loading = true);

    try {
      final response = await authController.signup(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      if (response?.user != null) {
        final UserService userService = UserService();
        await userService.addUserIfNotExists(user: response!.user!);

        // Show email confirmation dialog
        _showEmailConfirmationDialog();
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

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 12,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email icon with teal background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  "Confirm Your Email",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  "We've sent a confirmation email to\n${emailController.text.trim()}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Montserrat',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                const Text(
                  "Please verify your email before signing in.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/');
                    },
                    child: const Text(
                      "Got It!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top curved teal background
          ClipPath(
            clipper: CurvedClipper(),
            child: Container(
              height: size.height * 0.65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkTeal, Colors.teal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Signup content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.15),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign up to get started",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: size.height * 0.06),

                // Elevated Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.gold,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 36,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.alternate_email_rounded,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 25),
                          _buildPasswordField(),
                          const SizedBox(height: 40),

                          // Sign Up button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkTeal,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              onPressed: loading ? null : _signup,
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/'),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: AppColors.darkTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Password text field with toggle visibility
  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87, // Input text color
      ),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: const TextStyle(
          color: AppColors.darkTeal, // Hint/label text when not focused
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.darkTeal),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppColors.darkTeal,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.darkTeal, // Label text when focused/floating
          fontWeight: FontWeight.w600,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black26),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  } // Custom modern email text field

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87, // Input text color
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.darkTeal, // Hint/label text when not focused
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: AppColors.darkTeal),
        floatingLabelStyle: const TextStyle(
          color: AppColors.darkTeal, // Label text when focused/floating
          fontWeight: FontWeight.w600,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black26),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

// Custom clipper for long curved background
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 120);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 120,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
