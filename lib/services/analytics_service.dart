import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  final supabase = Supabase.instance.client;

  Future<MonthlySummary> getMonthlySummary(
    String userId,
    int year,
    int month,
  ) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final result = await supabase
        .from('transactions')
        .select('amount,type')
        .eq('user_id', userId)
        .gte('date', start)
        .lt('date', end);

    double income = 0;
    double expense = 0;

    for (final row in result) {
      final amt = double.tryParse(row['amount'].toString()) ?? 0;

      if (row['type'] == 'income') income += amt;
      if (row['type'] == 'expense') expense += amt;
    }

    return MonthlySummary(
      income: income,
      expense: expense,
      savings: income - expense,
    );
  }

  // For pie chart
  Future<List<CategoryBreakdown>> getExpenseBreakdown(
    String userId,
    int year,
    int month,
  ) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final result = await supabase.rpc(
      'expense_breakdown',
      params: {'userid': userId, 'startdate': start, 'enddate': end},
    );

    return (result as List)
        .map(
          (e) => CategoryBreakdown(
            category: e['category'],
            total: double.tryParse(e['total'].toString()) ?? 0,
          ),
        )
        .toList();
  }

  // Trend for last 6 months (line chart)
  Future<List<MonthlyTrend>> getLast6MonthTrend(String userId) async {
    final result = await supabase.rpc(
      'six_month_trend',
      params: {'userid': userId},
    );

    return (result as List)
        .map(
          (e) => MonthlyTrend(
            month: e['month'],
            income: (e['income'] as num).toDouble(),
            expense: (e['expense'] as num).toDouble(),
          ),
        )
        .toList();
  }
}
