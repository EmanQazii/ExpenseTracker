import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartOverview extends StatefulWidget {
  const ChartOverview({super.key});

  @override
  State<ChartOverview> createState() => _ChartOverviewState();
}

class _ChartOverviewState extends State<ChartOverview> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final data = [
      _ExpenseData(
        "Food",
        30,
        Colors.amber.withValues(alpha: 0.8),
        Icons.restaurant,
      ),
      _ExpenseData(
        "Transport",
        10,
        Colors.green.withValues(alpha: 0.8),
        Icons.directions_car,
      ),
      _ExpenseData(
        "Bills",
        20,
        Colors.redAccent.withValues(alpha: 0.8),
        Icons.receipt,
      ),
      _ExpenseData(
        "Other",
        40,
        Colors.indigo.withValues(alpha: 0.8),
        Icons.category,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isTouched = index == touchedIndex;
                final radius = isTouched ? 65.0 : 55.0;
                final fontSize = isTouched ? 16.0 : 14.0;

                return PieChartSectionData(
                  value: item.value,
                  title: "${item.value.toInt()}%",
                  color: item.color,
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              }).toList(),
              centerSpaceRadius: 50,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: data.map((item) {
            return _buildLegendItem(item, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(_ExpenseData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            data.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            "${data.value.toInt()}%",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseData {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  _ExpenseData(this.label, this.value, this.color, this.icon);
}
