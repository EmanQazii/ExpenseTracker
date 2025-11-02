import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_routes.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

final supabase = Supabase.instance.client;
const publicRoutes = [
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.resetPassword,
];
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => DashboardScreen(),
    ),
  ],

  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final isPublic = publicRoutes.contains(state.matchedLocation);
    if (state.matchedLocation == AppRoutes.splash) return null;

    if (session == null && !isPublic) {
      return AppRoutes.login;
    }
    if (session != null && isPublic) {
      return AppRoutes.dashboard;
    }

    return null;
  },
);
