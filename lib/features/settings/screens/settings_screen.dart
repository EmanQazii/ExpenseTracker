import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/settings_provider.dart';
import '../../../models/settings_model.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Map<String, dynamic>> currencyOptions = [
    {'code': 'PKR', 'name': 'Pakistani Rupee', 'symbol': '₨'},
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'ر.س'},
  ];

  Future<void> _updateTheme(AppThemeMode mode) async {
    final provider = context.read<SettingsProvider>();
    final success = await provider.updateTheme(mode);

    if (success) {
      _showSnackBar('Theme updated successfully');
    } else {
      _showSnackBar('Failed to update theme', isError: true);
    }
  }

  Future<void> _updateCurrency(String value) async {
    final provider = context.read<SettingsProvider>();
    final success = await provider.updateCurrency(value);

    if (success) {
      _showSnackBar('Currency updated successfully');
    } else {
      _showSnackBar('Failed to update currency', isError: true);
    }
  }

  Future<void> _updateBudgetAlerts(bool value) async {
    final provider = context.read<SettingsProvider>();
    await provider.updateBudgetAlerts(value);
  }

  Future<void> _updateNotifications(bool value) async {
    final provider = context.read<SettingsProvider>();
    await provider.updateNotifications(value);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (mounted) context.go("/login");
      } catch (e) {
        _showSnackBar('Failed to sign out', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.coral : AppColors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCurrencyPicker() {
    final provider = context.read<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencyOptions.length,
                itemBuilder: (context, index) {
                  final currency = currencyOptions[index];
                  final isSelected = provider.currency == currency['code'];

                  return ListTile(
                    leading: Text(
                      currency['symbol'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      currency['name'],
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.teal)
                        : Text(
                            currency['code'],
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                    selected: isSelected,
                    selectedTileColor: AppColors.teal.withOpacity(0.1),
                    onTap: () {
                      _updateCurrency(currency['code']);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedCurrency = currencyOptions.firstWhere(
      (c) => c['code'] == provider.currency,
      orElse: () => currencyOptions[0],
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(colors: [Colors.grey[800]!, Colors.grey[850]!])
                : AppColors.primaryGradient,
          ),
        ),
      ),
      body: !provider.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // APPEARANCE SECTION
                _buildSectionHeader('Appearance', isDark),
                _buildThemeSelector(provider, isDark),
                Divider(height: 1, color: isDark ? Colors.grey[800] : null),

                // CURRENCY SECTION
                _buildSectionHeader('Currency & Format', isDark),
                _buildCurrencyTile(selectedCurrency, isDark),
                Divider(height: 1, color: isDark ? Colors.grey[800] : null),

                // NOTIFICATIONS SECTION
                _buildSectionHeader('Notifications', isDark),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive expense reminders',
                  value: provider.notifications,
                  onChanged: _updateNotifications,
                  icon: Icons.notifications_outlined,
                  isDark: isDark,
                ),
                _buildSwitchTile(
                  title: 'Budget Alerts',
                  subtitle: 'Get notified when approaching budget limit',
                  value: provider.budgetAlerts,
                  onChanged: _updateBudgetAlerts,
                  icon: Icons.notification_important_outlined,
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[800] : null),

                // DATA & PRIVACY SECTION
                _buildSectionHeader('Data & Privacy', isDark),
                _buildTile(
                  title: 'Export Data',
                  subtitle: 'Download your expense data',
                  icon: Icons.download_outlined,
                  isDark: isDark,
                  onTap: () {
                    _showSnackBar('Export feature coming soon!');
                  },
                ),
                _buildTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  icon: Icons.delete_outline,
                  iconColor: AppColors.coral,
                  textColor: AppColors.coral,
                  isDark: isDark,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDark
                            ? Colors.grey[850]
                            : Colors.white,
                        title: Text(
                          'Delete Account',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        content: Text(
                          'This will permanently delete your account and all data. This action cannot be undone.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.black87,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.coral,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _showSnackBar('Account deletion coming soon!');
                    }
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.grey[800] : null),

                // ABOUT SECTION
                _buildSectionHeader('About', isDark),
                _buildTile(
                  title: 'Version',
                  subtitle: '1.0.0',
                  icon: Icons.info_outline,
                  isDark: isDark,
                  onTap: () {},
                ),
                _buildTile(
                  title: 'Terms of Service',
                  icon: Icons.description_outlined,
                  isDark: isDark,
                  onTap: () {},
                ),
                _buildTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  isDark: isDark,
                  onTap: () {},
                ),
                Divider(height: 1, color: isDark ? Colors.grey[800] : null),

                // SIGN OUT
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[400] : AppColors.darkTeal,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(SettingsProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: isDark ? Colors.grey[400] : AppColors.darkTeal,
              ),
              const SizedBox(width: 12),
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  AppThemeMode.light,
                  Icons.light_mode,
                  'Light',
                  provider.themeMode,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  AppThemeMode.dark,
                  Icons.dark_mode,
                  'Dark',
                  provider.themeMode,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  AppThemeMode.system,
                  Icons.brightness_auto,
                  'System',
                  provider.themeMode,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    AppThemeMode mode,
    IconData icon,
    String label,
    AppThemeMode currentMode,
    bool isDark,
  ) {
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () => _updateTheme(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal.withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.teal
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.teal
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(Map<String, dynamic> currency, bool isDark) {
    return ListTile(
      leading: Icon(
        Icons.attach_money,
        color: isDark ? Colors.grey[400] : AppColors.darkTeal,
      ),
      title: Text(
        'Currency',
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        '${currency['name']} (${currency['code']})',
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currency['symbol'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ],
      ),
      onTap: _showCurrencyPicker,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required bool isDark,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: isDark ? Colors.grey[400] : AppColors.darkTeal,
      ),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      value: value,
      activeColor: AppColors.teal,
      onChanged: onChanged,
    );
  }

  Widget _buildTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.grey[400] : AppColors.darkTeal),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isDark ? Colors.white : Colors.black),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
      onTap: onTap,
    );
  }
}
