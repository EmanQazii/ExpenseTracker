import 'package:flutter/material.dart';
import '../../../services/transaction_service.dart';
import '../../../models/transaction_model.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/transaction_widgets.dart';

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
        bool matchesType = selectedType == "all" || t.type == selectedType;

        bool matchesCategory =
            selectedCategory == "All" || t.category == selectedCategory;

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
        decoration: const BoxDecoration(gradient: AppColors.accentGradient),
        child: SafeArea(
          child: Column(
            children: [
              TransactionHeader(
                onBack: () => Navigator.pop(context),
                onRefresh: loadData,
              ),
              SummaryCards(
                income: _calculateTotal("income"),
                expense: _calculateTotal("expense"),
              ),
              TransactionTabBar(controller: _tabController),
              SearchAndFilter(
                searchQuery: searchQuery,
                selectedCategory: selectedCategory,
                categories: categories,
                onSearchChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    _applyFilters();
                  });
                },
                onSearchCleared: () {
                  setState(() {
                    searchQuery = "";
                    _applyFilters();
                  });
                },
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                    _applyFilters();
                  });
                },
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: loading
                      ? const TransactionLoadingWidget()
                      : TransactionListView(transactions: filteredTransactions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
