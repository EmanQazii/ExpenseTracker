import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/spending_trend.dart';
import '../../reports/widgets/expense_breakdown_section.dart';
import '../controllers/dashboard_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late DashboardController _dashboardController;
  int _currentIndex = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _dashboardController = DashboardController();
    userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      _dashboardController.loadDashboardData(userId!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dashboardController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.grey[50],
      body: ListenableBuilder(
        listenable: _dashboardController,
        builder: (context, _) {
          if (_dashboardController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => _dashboardController.refresh(userId!),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                      right: 16,
                      left: 16,
                    ),
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
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 14,
                      right: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Card
                        _buildAnimatedWidget(
                          delay: 0,
                          child: BalanceCard(
                            month: _dashboardController.getFormattedMonth(),
                            balance:
                                "Rs ${_dashboardController.netBalance.toStringAsFixed(0)}",
                            label: "Net Balance",
                            growth: _dashboardController.balanceGrowth,
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
                                  amount: _dashboardController.totalIncome,
                                  color: Colors.teal,
                                  icon: Icons.arrow_downward,
                                  percentage: _dashboardController.incomeGrowth,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SummaryCard(
                                  title: "Expenses",
                                  amount: _dashboardController.totalExpense,
                                  color: AppColors.coral,
                                  icon: Icons.arrow_upward,
                                  percentage:
                                      _dashboardController.expenseGrowth,
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
                            amount: _dashboardController.netBalance,
                            color: AppColors.gold,
                            icon: Icons.savings_outlined,
                            percentage: _dashboardController.savingsGrowth,
                            isWide: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Recent Transactions
                        if (_dashboardController.recentTransactions.isNotEmpty)
                          _buildAnimatedWidget(
                            delay: 500,
                            child: _buildRecentTransactions(isDark),
                          ),

                        const SizedBox(height: 24),

                        // Expense Breakdown Chart
                        if (_dashboardController.categoryBreakdown.isNotEmpty)
                          _buildAnimatedWidget(
                            delay: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Expense Overview",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.darkTeal,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.go(AppRoutes.analytics);
                                        },
                                        child: const Text("View Details"),
                                      ),
                                    ],
                                  ),
                                ),
                                ExpenseBreakdownSection(
                                  breakdown:
                                      _dashboardController.categoryBreakdown,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Spending Trend
                        if (_dashboardController.monthlyTrend.isNotEmpty)
                          _buildAnimatedWidget(
                            delay: 300,
                            child: SpendingTrend(
                              monthlyTrend: _dashboardController.monthlyTrend,
                            ),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildAnimatedWidget(
        delay: 600,
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
          selectedItemColor: AppColors.teal,
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

  Widget _buildRecentTransactions(bool isDark) {
    return Container(
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
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go(AppRoutes.transactions);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.teal),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                child: const Text("See All"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dashboardController.recentTransactions.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final transaction =
                  _dashboardController.recentTransactions[index];
              return _buildTransactionItem(transaction, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction, bool isDark) {
    final isIncome = transaction.type == 'income';
    final icon = _getCategoryIcon(transaction.category);
    final color = _getCategoryColor(transaction.category, isIncome);

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.date),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${isIncome ? '+' : '-'}Rs ${transaction.amount.toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isIncome ? AppColors.teal : AppColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('food') ||
        categoryLower.contains('restaurant')) {
      return Icons.restaurant;
    } else if (categoryLower.contains('transport') ||
        categoryLower.contains('taxi')) {
      return Icons.local_taxi;
    } else if (categoryLower.contains('shopping') ||
        categoryLower.contains('grocery')) {
      return Icons.shopping_cart;
    } else if (categoryLower.contains('bill') ||
        categoryLower.contains('utility')) {
      return Icons.receipt_long;
    } else if (categoryLower.contains('salary') ||
        categoryLower.contains('income')) {
      return Icons.account_balance_wallet;
    } else if (categoryLower.contains('entertainment')) {
      return Icons.movie;
    } else if (categoryLower.contains('health')) {
      return Icons.local_hospital;
    } else {
      return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String category, bool isIncome) {
    if (isIncome) return AppColors.teal;

    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('food')) return AppColors.gold;
    if (categoryLower.contains('transport')) return Colors.indigo;
    if (categoryLower.contains('shopping')) return AppColors.darkTeal;
    if (categoryLower.contains('bill')) return Colors.teal;
    if (categoryLower.contains('entertainment')) return Colors.deepPurpleAccent;
    if (categoryLower.contains('health')) return Colors.green;
    return AppColors.coral;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
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
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    }
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
}
