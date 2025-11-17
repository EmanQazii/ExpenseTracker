import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<void> addUserIfNotExists({required User user}) async {
    try {
      await supabase.from('users').upsert({'id': user.id, 'email': user.email});
    } catch (e) {
      print("ERROR adding user to users table: $e");
    }
  }
}
