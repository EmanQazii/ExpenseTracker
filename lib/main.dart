import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Ensure all Flutter bindings are initialized before plugins run
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Monthly Expense Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
