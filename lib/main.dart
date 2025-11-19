import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'router/app_router.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'config/app_theme.dart';

Future<void> main() async {
  // Ensure all Flutter bindings are initialized before plugins run
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Initialize notification service
  try {
    await NotificationService().initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Error initializing notification service: $e');
    // Continue even if notifications fail to initialize
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen for password recovery events
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        // User clicked the reset password link in email
        // Navigate to update password screen
        appRouter.go('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
          // Don't initialize here - let splash screen handle it
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'SpendWise - Expense Tracker',
            debugShowCheckedModeBanner: false,

            // Apply theme based on settings
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.flutterThemeMode,

            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
