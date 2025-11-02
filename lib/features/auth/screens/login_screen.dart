import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkTeal, AppColors.darkTeal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Login content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.18),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to continue",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: size.height * 0.06),

                // Hovered Card
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
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.alternate_email_rounded,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 25),
                          _buildPasswordField(),
                          const SizedBox(height: 40),

                          // Sign In button
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
                              onPressed: () {
                                context.go(AppRoutes.dashboard);
                              },
                              child: const Text(
                                "Sign In",
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

                          // Sign Up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go(AppRoutes.signup);
                                },
                                child: const Text(
                                  "Sign Up",
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

  // Custom modern email text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.darkTeal),
        floatingLabelStyle: const TextStyle(
          color: AppColors.darkTeal,
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

  // Password text field with toggle visibility
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: "Password",
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
          color: AppColors.darkTeal,
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
