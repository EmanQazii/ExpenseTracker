import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double amount;
  final Color color;
  final Color iconBg;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            "Rs ${amount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}
