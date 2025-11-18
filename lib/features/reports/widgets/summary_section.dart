import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/analytics_model.dart';
import 'summary_card.dart';
import 'savings_card.dart';

class SummarySection extends StatelessWidget {
  final MonthlySummary summary;

  const SummarySection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Monthly Overview",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                icon: Icons.arrow_downward,
                title: "Income",
                amount: summary.income,
                color: AppColors.teal,
                iconBg: AppColors.teal.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                icon: Icons.arrow_upward,
                title: "Expenses",
                amount: summary.expense,
                color: AppColors.coral,
                iconBg: AppColors.coral.withOpacity(0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SavingsCard(savings: summary.savings),
      ],
    );
  }
}
