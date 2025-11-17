import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SavingsCard extends StatelessWidget {
  final double savings;

  const SavingsCard({super.key, required this.savings});

  @override
  Widget build(BuildContext context) {
    final isPositive = savings >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppColors.teal, AppColors.darkTeal]
              : [AppColors.coral, Colors.red[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? AppColors.teal : AppColors.coral).withOpacity(
              0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPositive ? "💰 You Saved" : "⚠️ Overspent",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                "Rs ${savings.abs().toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }
}
