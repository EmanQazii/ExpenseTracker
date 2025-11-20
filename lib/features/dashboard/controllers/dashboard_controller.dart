import 'package:flutter/material.dart';
import '../../../services/transaction_service.dart';
import '../../../services/analytics_service.dart';
import '../../../models/transaction_model.dart';
import '../../../models/analytics_model.dart';

class DashboardController extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Monthly Summary Data
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _netBalance = 0;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get netBalance => _netBalance;

  // Growth percentages
  String _incomeGrowth = "+0%";
  String _expenseGrowth = "+0%";
  String _savingsGrowth = "+0%";
  String _balanceGrowth = "+0%";

  String get incomeGrowth => _incomeGrowth;
  String get expenseGrowth => _expenseGrowth;
  String get savingsGrowth => _savingsGrowth;
  String get balanceGrowth => _balanceGrowth;

  // Recent Transactions
  List<TransactionModel> _recentTransactions = [];
  List<TransactionModel> get recentTransactions => _recentTransactions;

  // Category Breakdown for Chart
  List<CategoryBreakdown> _categoryBreakdown = [];
  List<CategoryBreakdown> get categoryBreakdown => _categoryBreakdown;

  // Monthly Trend for Spending Chart
  List<MonthlyTrend> _monthlyTrend = [];
  List<MonthlyTrend> get monthlyTrend => _monthlyTrend;

  // Current month/year
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  Future<void> loadDashboardData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load all data in parallel for better performance
      await Future.wait([
        _loadMonthlySummary(userId),
        _loadRecentTransactions(),
        _loadCategoryBreakdown(userId),
        _loadMonthlyTrend(userId),
      ]);

      _calculateGrowth(userId);
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMonthlySummary(String userId) async {
    final summary = await _analyticsService.getMonthlySummary(
      userId,
      _currentYear,
      _currentMonth,
    );

    _totalIncome = summary.income;
    _totalExpense = summary.expense;
    _netBalance = summary.savings;
  }

  Future<void> _loadRecentTransactions() async {
    final allTransactions = await _transactionService.fetchTransactions();
    // Get only the 5 most recent transactions
    _recentTransactions = allTransactions.take(5).toList();
  }

  Future<void> _loadCategoryBreakdown(String userId) async {
    _categoryBreakdown = await _analyticsService.getExpenseBreakdown(
      userId,
      _currentYear,
      _currentMonth,
    );
  }

  Future<void> _loadMonthlyTrend(String userId) async {
    _monthlyTrend = await _analyticsService.getLast6MonthTrend(userId);
  }

  Future<void> _calculateGrowth(String userId) async {
    try {
      // Get previous month's data
      int prevMonth = _currentMonth - 1;
      int prevYear = _currentYear;

      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear--;
      }

      final previousSummary = await _analyticsService.getMonthlySummary(
        userId,
        prevYear,
        prevMonth,
      );

      // Calculate growth percentages
      if (previousSummary.income > 0) {
        final incomeChange =
            ((_totalIncome - previousSummary.income) / previousSummary.income) *
            100;
        _incomeGrowth =
            "${incomeChange >= 0 ? '+' : ''}${incomeChange.toStringAsFixed(1)}%";
      }

      if (previousSummary.expense > 0) {
        final expenseChange =
            ((_totalExpense - previousSummary.expense) /
                previousSummary.expense) *
            100;
        _expenseGrowth =
            "${expenseChange >= 0 ? '+' : ''}${expenseChange.toStringAsFixed(1)}%";
      }

      if (previousSummary.savings > 0) {
        final savingsChange =
            ((_netBalance - previousSummary.savings) /
                previousSummary.savings) *
            100;
        _savingsGrowth =
            "${savingsChange >= 0 ? '+' : ''}${savingsChange.toStringAsFixed(1)}%";
        _balanceGrowth = _savingsGrowth; // Same as savings growth
      }
    } catch (e) {
      debugPrint("Error calculating growth: $e");
      // Keep default values if calculation fails
    }
  }

  Future<void> refresh(String userId) async {
    await loadDashboardData(userId);
  }

  String getFormattedMonth() {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[_currentMonth - 1]} $_currentYear";
  }
}
