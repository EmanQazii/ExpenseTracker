import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_routes.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/update_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../features/transactions/screens/view_transaction_screen.dart';
import '../features/reports/screens/analytics_screen.dart';
import '../features/settings/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/dashboard/screens/notification_screen.dart';

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
      path: AppRoutes.updatePassword,
      builder: (context, state) => const UpdatePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: 'notifications',
          builder: (context, state) => NotificationsScreen(),
        ),
        GoRoute(
          path: 'transactions',
          builder: (context, state) => TransactionScreen(),
        ),
        GoRoute(
          path: 'analytics',
          builder: (context, state) => AnalyticsScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => SettingsScreen(),
        ),
        GoRoute(path: 'profile', builder: (context, state) => ProfileScreen()),
        GoRoute(
          path: 'add-transaction',
          builder: (context, state) => AddTransactionScreen(),
        ),
      ],
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
