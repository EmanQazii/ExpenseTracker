import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/chart_overview.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/spending_trend.dart';
import '../widgets/quick_actions.dart';
import '../widgets/balance_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentIndex = 0;
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (mounted) context.go("/login");
      } catch (e) {
        _showSnackBar('Failed to sign out', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now();
    final formattedMonth =
        "${_monthName(currentMonth.month)} ${currentMonth.year}";
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 50, right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Notification Icon with Badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: isDark ? Colors.white : AppColors.darkTeal,
                        iconSize: 26,
                        onPressed: () {
                          context.push("/dashboard/notifications");
                        },
                      ),
                      // Badge indicator if notifications are enabled
                      if (settingsProvider.notifications)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.coral,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF0A0E21)
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkTeal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    color: isDark ? Colors.white : AppColors.darkTeal,
                    iconSize: 28,
                    onPressed: () {
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 14, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month and Balance Header
                  _buildAnimatedWidget(
                    delay: 0,
                    child: BalanceCard(
                      month: formattedMonth,
                      balance: "Rs 21,000",
                      label: "Net Balance",
                      growth: "+12.5%",
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Summary Cards
                  _buildAnimatedWidget(
                    delay: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "Income",
                            amount: 52000,
                            color: AppColors.coral,
                            icon: Icons.arrow_downward,
                            percentage: "+8.5%",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryCard(
                            title: "Expenses",
                            amount: 31000,
                            color: Colors.teal,
                            icon: Icons.arrow_upward,
                            percentage: "+3.2%",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAnimatedWidget(
                    delay: 200,
                    child: SummaryCard(
                      title: "Savings",
                      amount: 21000,
                      color: Colors.amber,
                      icon: Icons.savings_outlined,
                      percentage: "+15.3%",
                      isWide: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildAnimatedWidget(delay: 300, child: const QuickActions()),
                  const SizedBox(height: 24),

                  // Spending Trend
                  _buildAnimatedWidget(
                    delay: 400,
                    child: const SpendingTrend(),
                  ),
                  const SizedBox(height: 24),

                  // Expense Breakdown Chart
                  _buildAnimatedWidget(
                    delay: 500,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1D1E33) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Expense Breakdown",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.teal,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                child: const Text("View All"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const ChartOverview(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  _buildAnimatedWidget(
                    delay: 600,
                    child: const RecentTransactions(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAnimatedWidget(
        delay: 700,
        child: FloatingActionButton.extended(
          onPressed: () {
            context.push(AppRoutes.addTransaction);
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Transaction",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          elevation: 8,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1D1E33) : Colors.white,
          onTap: (index) {
            setState(() => _currentIndex = index);

            switch (index) {
              case 0:
                context.go(AppRoutes.dashboard);
                break;
              case 1:
                context.go(AppRoutes.transactions);
                break;
              case 2:
                context.go(AppRoutes.analytics);
                break;
              case 3:
                context.go(AppRoutes.settings);
                break;
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Transactions",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: "Analytics",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedWidget({required int delay, required Widget child}) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 1000,
            (delay + 200) / 1000,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay / 1000,
                  (delay + 200) / 1000,
                  curve: Curves.easeOut,
                ),
              ),
            ),
        child: child,
      ),
    );
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
}
