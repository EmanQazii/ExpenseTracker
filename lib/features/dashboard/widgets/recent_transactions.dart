import 'package:flutter/material.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final transactions = [
      _Transaction(
        "Grocery Shopping",
        -1250,
        Icons.shopping_cart,
        Colors.orangeAccent,
        "Today, 2:30 PM",
      ),
      _Transaction(
        "Salary Deposit",
        52000,
        Icons.account_balance,
        const Color.fromARGB(255, 8, 102, 93),
        "Nov 1, 2025",
      ),
      _Transaction(
        "Electricity Bill",
        -2500,
        Icons.bolt,
        Colors.redAccent,
        "Nov 10, 2025",
      ),
      _Transaction(
        "Uber Ride",
        -450,
        Icons.local_taxi,
        Colors.teal,
        "Yesterday, 9:15 AM",
      ),
      _Transaction(
        "Restaurant",
        -1800,
        Icons.restaurant,
        Colors.amber,
        "Nov 11, 2025",
      ),
    ];

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
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.teal),
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
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionItem(transaction, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(_Transaction transaction, bool isDark) {
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
                color: transaction.color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(transaction.icon, color: Colors.white, size: 24),
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
                    transaction.date,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${transaction.amount > 0 ? '+' : ''}Rs ${transaction.amount.abs().toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: transaction.amount > 0 ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Transaction {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String date;

  _Transaction(this.title, this.amount, this.icon, this.color, this.date);
}
