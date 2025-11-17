class MonthlySummary {
  final double income;
  final double expense;
  final double savings;

  MonthlySummary({
    required this.income,
    required this.expense,
    required this.savings,
  });
}

class CategoryBreakdown {
  final String category;
  final double total;

  CategoryBreakdown({required this.category, required this.total});
}

class MonthlyTrend {
  final String month;
  final double income;
  final double expense;

  MonthlyTrend({
    required this.month,
    required this.income,
    required this.expense,
  });
}
