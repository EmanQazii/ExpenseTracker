import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/analytics_model.dart';
import '../../../providers/settings_provider.dart';

class ExpenseBreakdownSection extends StatelessWidget {
  final List<CategoryBreakdown> breakdown;

  const ExpenseBreakdownSection({super.key, required this.breakdown});

  static const categoryColors = [
    AppColors.coral,
    AppColors.teal,
    AppColors.gold,
    AppColors.darkTeal,
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = breakdown.fold(0.0, (sum, item) => sum + item.total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1D1E33).withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Spending by Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: breakdown.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final percentage = (item.total / total * 100);

                  return PieChartSectionData(
                    value: item.total,
                    title: "${percentage.toStringAsFixed(1)}%",
                    radius: 60,
                    color: categoryColors[idx % categoryColors.length],
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: breakdown.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final percentage = (item.total / total * 100);

              return _LegendItem(
                color: categoryColors[idx % categoryColors.length],
                label: item.category,
                amount: item.total,
                percentage: percentage,
                currencySymbol: settingsProvider.currencySymbol,
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  final double percentage;
  final String currencySymbol;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.currencySymbol,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            "$label • $currencySymbol ${amount.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
