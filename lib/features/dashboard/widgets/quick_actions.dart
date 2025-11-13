import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actions = [
      _QuickAction("Send", Icons.send_rounded, Colors.indigo),
      _QuickAction("Request", Icons.call_received_rounded, Colors.green),
      _QuickAction("Bills", Icons.receipt_long_rounded, Colors.amber),
      _QuickAction("More", Icons.apps_rounded, Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildActionButton(action, isDark),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(_QuickAction action, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1E33) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: action.color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;

  _QuickAction(this.label, this.icon, this.color);
}
