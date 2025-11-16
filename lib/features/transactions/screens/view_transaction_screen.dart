import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/transaction_service.dart';
import '../../../models/transaction_model.dart';
import '../../../core/constants/app_colors.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  final service = TransactionService();
  List<TransactionModel> transactions = [];
  List<TransactionModel> filteredTransactions = [];
  bool loading = true;

  // Filter states
  String selectedType = "all"; // all, income, expense
  String selectedCategory = "All";
  String searchQuery = "";

  late TabController _tabController;

  final List<String> categories = [
    "All",
    "General",
    "Food",
    "Bills",
    "Shopping",
    "Travel",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 0) {
          selectedType = "all";
        } else if (_tabController.index == 1) {
          selectedType = "income";
        } else {
          selectedType = "expense";
        }
        _applyFilters();
      });
    }
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    final data = await service.fetchTransactions();
    setState(() {
      transactions = data;
      filteredTransactions = data;
      loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredTransactions = transactions.where((t) {
        // Type filter
        bool matchesType = selectedType == "all" || t.type == selectedType;

        // Category filter
        bool matchesCategory =
            selectedCategory == "All" || t.category == selectedCategory;

        // Search filter
        bool matchesSearch =
            searchQuery.isEmpty ||
            t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            t.category.toLowerCase().contains(searchQuery.toLowerCase());

        return matchesType && matchesCategory && matchesSearch;
      }).toList();
    });
  }

  double _calculateTotal(String type) {
    return filteredTransactions
        .where((t) => type == "all" || t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSummaryCards(),
              _buildTabBar(),
              _buildSearchAndFilter(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: loading ? _buildLoading() : _buildTransactionList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              onPressed: () => Navigator.pop(context),
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
              onPressed: loadData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final income = _calculateTotal("income");
    final expense = _calculateTotal("expense");
    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              "Income",
              income,
              AppColors.teal,
              Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              "Expense",
              expense,
              AppColors.coral,
              Icons.trending_down,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Rs ${amount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.darkTeal,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
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

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: "Search transactions...",
                hintStyle: TextStyle(color: AppColors.white.withOpacity(0.6)),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.white.withOpacity(0.8),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                        onPressed: () {
                          setState(() {
                            searchQuery = "";
                            _applyFilters();
                          });
                        },
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
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        _applyFilters();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.darkTeal
                              : AppColors.white.withOpacity(0.9),
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

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.teal),
    );
  }

  Widget _buildTransactionList() {
    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    // Group transactions by date
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var transaction in filteredTransactions) {
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
            ...dayTransactions.map((t) => _buildTransactionCard(t)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

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

  Widget _buildTransactionCard(TransactionModel t) {
    final isIncome = t.type == "income";
    final color = isIncome ? AppColors.teal : AppColors.coral;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getCategoryIcon(t.category), color: color, size: 24),
        ),
        title: Text(
          t.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTeal,
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
                  t.category,
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
          "${isIncome ? '+' : '-'} Rs ${t.amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const Text(
            "No transactions found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters!",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
