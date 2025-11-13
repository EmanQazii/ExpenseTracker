import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late Animation<double> _logoAnimation;
  late Animation<double> _taglineAnimation;
  final List<String> taglineWords = ['Track.', 'Analyze.', 'Grow.'];
  final List<AnimationController> _taglineWordControllers = [];
  final List<Animation<Offset>> _taglineWordAnimations = [];

  final String appName = 'SpendWise';
  final List<AnimationController> _letterControllers = [];
  final List<Animation<Offset>> _letterAnimations = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashSequence();
    });
  }

  void _initAnimations() {
    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Text letter-by-letter animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create animation for each letter
    for (int i = 0; i < appName.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _letterControllers.add(controller);

      final animation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          );
      _letterAnimations.add(animation);
    }

    // Tagline animation
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineAnimation = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    );
    for (int i = 0; i < taglineWords.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      final animation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          );

      _taglineWordControllers.add(controller);
      _taglineWordAnimations.add(animation);
    }
  }

  Future<void> _startSplashSequence() async {
    // Start logo animation
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // Start letter animations one by one
    for (int i = 0; i < _letterControllers.length; i++) {
      _letterControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 60));
    }
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _taglineWordControllers.length; i++) {
      _taglineWordControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 250));
    }

    await Future.delayed(const Duration(seconds: 2));

    final session = supabase.auth.currentSession;
    if (!mounted) return;

    if (session != null) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    for (var controller in _letterControllers) {
      controller.dispose();
    }
    for (var controller in _taglineWordControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkTeal, AppColors.teal],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              ScaleTransition(
                scale: _logoAnimation,
                child: _buildTransparentLogo(),
              ),
              const SizedBox(height: 48),

              // Letter-by-letter animated text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  appName.length,
                  (index) => ClipRect(
                    child: SlideTransition(
                      position: _letterAnimations[index],
                      child: Text(
                        appName[index],
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: -1.5,
                          fontFamily: 'Poppins',
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tagline with fade animation
              FadeTransition(
                opacity: _taglineAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    taglineWords.length,
                    (index) => SlideTransition(
                      position: _taglineWordAnimations[index],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          taglineWords[index],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // Outer glow circle
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Main donut chart
          Center(
            child: CustomPaint(
              size: const Size(100, 100),
              painter: ModernChartPainter(),
            ),
          ),

          // Center dollar sign
          Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                    fontFamily: 'Poppins', // You'll need to add this
                  ),
                ),
              ),
            ),
          ),

          // Sparkle effect
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 12,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw pie segments with gaps
    final segments = [
      {'color': AppColors.coral, 'start': -1.57, 'sweep': 1.3},
      {'color': AppColors.gold, 'start': -0.27, 'sweep': 1.5},
      {'color': AppColors.teal, 'start': 1.23, 'sweep': 1.2},
      {'color': AppColors.darkTeal, 'start': 2.43, 'sweep': 1.4},
    ];

    for (var segment in segments) {
      final paint = Paint()
        ..color = segment['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        segment['start'] as double,
        segment['sweep'] as double,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
