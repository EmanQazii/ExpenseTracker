import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final supabase = Supabase.instance.client;

  Future<List<TransactionModel>> fetchTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    return (response as List).map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<void> addTransaction(TransactionModel t) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "User not logged in";

      final response = await supabase.from('transactions').insert({
        ...t.toMap(),
        'user_id': user.id,
      });

      if (response is PostgrestException) {
        throw response.message;
      }
    } catch (e) {
      print("ERROR inserting transaction: $e");
      rethrow;
    }
  }
}
