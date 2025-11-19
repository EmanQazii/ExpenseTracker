import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';

class AuthController {
  final _supabase = SupabaseService();

  Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await _supabase.signIn(email, password);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse?> signup(String email, String password) async {
    try {
      final response = await _supabase.signUp(email, password);

      if (response.user == null) {
        throw response.session != null
            ? Exception('Unexpected response.')
            : Exception('Signup failed.');
      }

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.resetPassword(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final supabase = Supabase.instance.client;

      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (res.user == null) {
        throw Exception('Failed to update password');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabase.signOut();
  }
}
