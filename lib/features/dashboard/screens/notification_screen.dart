import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SettingsProvider>();

    // Mock notifications - you can replace this with actual notification history
    final notifications = _getMockNotifications();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1D1E33) : AppColors.darkTeal,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () async {
              // Test notification immediately
              await provider.testNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test notification sent!'),
                  backgroundColor: AppColors.teal,
                ),
              );
            },
            icon: const Icon(Icons.bug_report, color: Colors.white, size: 20),
            label: const Text('Test', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Notification Settings Status
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D1E33) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: provider.notifications
                    ? AppColors.teal.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: provider.notifications
                        ? AppColors.teal.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    provider.notifications
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: provider.notifications
                        ? AppColors.teal
                        : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.notifications
                            ? 'Notifications Enabled'
                            : 'Notifications Disabled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.notifications
                            ? 'You\'ll receive reminders and alerts'
                            : 'Enable in settings to receive alerts',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: provider.notifications ? AppColors.teal : Colors.grey,
                ),
              ],
            ),
          ),

          // Test Actions Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D1E33) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.science, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Test Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TestNotificationButton(
                  icon: Icons.warning_amber,
                  label: 'Budget Alert (75%)',
                  description: 'Simulate 75% budget usage',
                  color: Colors.orange,
                  onTap: () async {
                    await provider.checkBudgetAlert(
                      category: 'Food',
                      spent: 75000,
                      budget: 100000,
                    );
                    _showSnackBar(context, 'Budget alert (75%) sent!');
                  },
                ),
                const SizedBox(height: 8),
                _TestNotificationButton(
                  icon: Icons.warning,
                  label: 'Budget Warning (90%)',
                  description: 'Simulate 90% budget usage',
                  color: Colors.deepOrange,
                  onTap: () async {
                    await provider.checkBudgetAlert(
                      category: 'Shopping',
                      spent: 90000,
                      budget: 100000,
                    );
                    _showSnackBar(context, 'Budget warning (90%) sent!');
                  },
                ),
                const SizedBox(height: 8),
                _TestNotificationButton(
                  icon: Icons.error,
                  label: 'Budget Exceeded (110%)',
                  description: 'Simulate budget exceeded',
                  color: AppColors.coral,
                  onTap: () async {
                    await provider.checkBudgetAlert(
                      category: 'Entertainment',
                      spent: 110000,
                      budget: 100000,
                    );
                    _showSnackBar(context, 'Budget exceeded alert sent!');
                  },
                ),
                const SizedBox(height: 8),
                _TestNotificationButton(
                  icon: Icons.check_circle,
                  label: 'Success Message',
                  description: 'Expense added notification',
                  color: Colors.green,
                  onTap: () async {
                    await provider.sendNotification(
                      title: '✅ Expense Added',
                      body: '${provider.currencySymbol} 500 added to Food',
                    );
                    _showSnackBar(context, 'Success notification sent!');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Notifications Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Notification List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Test notifications will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        icon: notification['icon'],
                        title: notification['title'],
                        body: notification['body'],
                        time: notification['time'],
                        color: notification['color'],
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockNotifications() {
    // Return empty for now - you can add notification history later
    return [];
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TestNotificationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _TestNotificationButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.send, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final bool isDark;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
