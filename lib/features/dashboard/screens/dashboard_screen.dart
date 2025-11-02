import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: Center(child: Text("Welcome ${user?.email ?? 'Guest'}")),
    );
  }
}
