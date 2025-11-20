import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../contollers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authController = AuthController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('🔐 Attempting login with email: $email');

      final response = await authController.login(email, password);

      // Check if widget is still mounted
      if (!mounted) return;

      if (response != null &&
          response.user != null &&
          response.session != null) {
        debugPrint('✅ Login successful: ${response.user!.email}');

        // Show success message
        _showMessage('Login successful!');

        // Small delay before navigation
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigate to dashboard
        context.go(AppRoutes.dashboard);
      } else {
        _showMessage('Invalid email or password', isError: true);
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');

      if (!mounted) return;

      String errorMessage = 'Login failed';

      // Handle specific error types
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please verify your email first';
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
      }

      _showMessage(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

                // Card with form
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
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 25),
                          _buildPasswordField(),

                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      context.go(AppRoutes.resetPassword);
                                    },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppColors.darkTeal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),

                          // Sign In button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkTeal,
                                disabledBackgroundColor: AppColors.darkTeal
                                    .withOpacity(0.6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
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
                          const SizedBox(height: 15),

                          // Sign Up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
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
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      enabled: enabled,
      textInputAction: TextInputAction.next,
      style: TextStyle(
        fontSize: 15,
        color: enabled ? Colors.black87 : Colors.black54,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? AppColors.darkTeal
              : AppColors.darkTeal.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled
              ? AppColors.darkTeal
              : AppColors.darkTeal.withOpacity(0.5),
        ),
        floatingLabelStyle: TextStyle(
          color: enabled
              ? AppColors.darkTeal
              : AppColors.darkTeal.withOpacity(0.5),
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
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
      ),
    );
  }

  // Password text field with toggle visibility
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isLoading,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleLogin(),
      style: TextStyle(
        fontSize: 15,
        color: _isLoading ? Colors.black54 : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(
          color: _isLoading
              ? AppColors.darkTeal.withOpacity(0.5)
              : AppColors.darkTeal,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.lock_rounded,
          color: _isLoading
              ? AppColors.darkTeal.withOpacity(0.5)
              : AppColors.darkTeal,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: _isLoading
                ? AppColors.darkTeal.withOpacity(0.5)
                : AppColors.darkTeal,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
        ),
        floatingLabelStyle: TextStyle(
          color: _isLoading
              ? AppColors.darkTeal.withOpacity(0.5)
              : AppColors.darkTeal,
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
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: _isLoading ? Colors.grey[200] : Colors.grey[100],
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
