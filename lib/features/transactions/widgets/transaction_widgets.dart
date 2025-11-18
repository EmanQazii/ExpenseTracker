import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';

class TransactionHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const TransactionHeader({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
              ),
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Transactions",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.white),
              onPressed: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCards extends StatelessWidget {
  final double income;
  final double expense;

  const SummaryCards({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              label: "Income",
              amount: income,
              color: Colors.teal,
              icon: Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              label: "Expense",
              amount: expense,
              color: AppColors.coral,
              icon: Icons.trending_down,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            settings.formatAmount(amount, showSymbol: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TransactionTabBar extends StatelessWidget {
  final TabController controller;

  const TransactionTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: isDark ? Colors.grey[850] : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: isDark ? Colors.white : AppColors.darkTeal,
          unselectedLabelColor: isDark
              ? Colors.grey[200]
              : AppColors.white.withOpacity(0.9),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Income"),
            Tab(text: "Expense"),
          ],
        ),
      ),
    );
  }
}

class SearchAndFilter extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchCleared;
  final Function(String) onCategorySelected;

  const SearchAndFilter({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.categories,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]
                  : AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.grey[700]!
                    : AppColors.white.withOpacity(0.2),
              ),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(color: isDark ? Colors.white : Colors.grey[800]),
              decoration: InputDecoration(
                hintText: "Search transactions...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[800],
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark
                              ? Colors.grey[400]
                              : AppColors.white.withOpacity(0.8),
                        ),
                        onPressed: onSearchCleared,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Category filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.grey[850] : AppColors.white)
                            : (AppColors.gold),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.grey[700]! : AppColors.white)
                              : (AppColors.gold.withOpacity(0.2)),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.darkTeal)
                              : (isDark
                                    ? Colors.grey[200]
                                    : AppColors.white.withOpacity(0.9)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Bills":
        return Icons.receipt_long;
      case "Shopping":
        return Icons.shopping_bag;
      case "Travel":
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == "income";
    final color = isIncome ? AppColors.teal : AppColors.coral;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final borderColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200;
    final textColor = isDark ? AppColors.white : AppColors.darkTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          transaction.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          "${isIncome ? '+' : '-'} ${settings.formatAmount(transaction.amount)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class TransactionEmptyState extends StatelessWidget {
  const TransactionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.darkTeal;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No transactions found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters!",
              style: TextStyle(fontSize: 14, color: subtextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionLoadingWidget extends StatelessWidget {
  const TransactionLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.teal),
    );
  }
}

class TransactionListView extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionListView({super.key, required this.transactions});

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return "Today";
    } else if (transactionDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? AppColors.white : AppColors.darkTeal;

    if (transactions.isEmpty) {
      return const TransactionEmptyState();
    }

    // Group transactions by date
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
            ),
            ...dayTransactions.map((t) => TransactionCard(transaction: t)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
