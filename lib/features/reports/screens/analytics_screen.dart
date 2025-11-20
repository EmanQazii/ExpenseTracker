import 'package:expense_tracker/router/app_router.dart';
import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';
import '../../../models/analytics_model.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_section.dart';
import '../widgets/expense_breakdown_section.dart';
import '../widgets/trend_section.dart';
import '../widgets/comparison_section.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final service = AnalyticsService();
  late String userId;
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  MonthlySummary? summary;
  List<CategoryBreakdown>? breakdown;
  List<MonthlyTrend>? trend;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    summary = await service.getMonthlySummary(
      userId,
      currentYear,
      currentMonth,
    );
    breakdown = await service.getExpenseBreakdown(
      userId,
      currentYear,
      currentMonth,
    );
    trend = await service.getLast6MonthTrend(userId);

    setState(() => loading = false);
  }

  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[currentMonth - 1];
  }

  void _goToPreviousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
    });
    loadData();
  }

  void _goToNextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0A0E21) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("Financial Insights"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark
            ? const Color.fromARGB(235, 245, 184, 2)
            : AppColors.darkTeal,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Selector
                    MonthSelector(
                      month: monthName,
                      year: currentYear,
                      onPrevious: _goToPreviousMonth,
                      onNext: _goToNextMonth,
                    ),

                    const SizedBox(height: 24),

                    // Summary Cards
                    SummarySection(summary: summary!),

                    const SizedBox(height: 32),

                    // Expense Breakdown
                    if (breakdown != null && breakdown!.isNotEmpty)
                      ExpenseBreakdownSection(breakdown: breakdown!),

                    const SizedBox(height: 32),

                    // Trend Charts
                    if (trend != null && trend!.isNotEmpty) ...[
                      TrendSection(trend: trend!),
                      const SizedBox(height: 32),
                      ComparisonSection(trend: trend!),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
