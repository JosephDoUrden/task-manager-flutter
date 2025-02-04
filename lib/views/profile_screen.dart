import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'settings/edit_profile_screen.dart';
import 'settings/notifications_screen.dart';
import 'settings/privacy_security_screen.dart';
import 'settings/help_support_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(
        () {
          final user = authController.userModel.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProfileImage(user.photoUrl, theme),
                          const SizedBox(height: 12),
                          Text(
                            user.displayName ?? 'User',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _showSignOutDialog(context, authController),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(context, user),
                      const SizedBox(height: 24),
                      _buildAccountInfo(context, user),
                      const SizedBox(height: 24),
                      _buildSettingsSection(context, authController),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(String? photoUrl, ThemeData theme) {
    return Hero(
      tag: 'profile_image',
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: photoUrl != null && photoUrl.startsWith('data:image')
              ? Image.memory(
                  base64Decode(photoUrl.split(',').last),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildDefaultProfileImage(theme),
                )
              : _buildDefaultProfileImage(theme),
        ),
      ),
    );
  }

  Widget _buildDefaultProfileImage(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.3),
      child: Icon(
        Icons.person_rounded,
        size: 50,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.edit_rounded,
          label: 'Edit Profile',
          onTap: () => Get.to(() => const EditProfileScreen()),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.notifications_rounded,
          label: 'Notifications',
          onTap: () => Get.to(() => const NotificationsScreen()),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.security_rounded,
          label: 'Security',
          onTap: () => Get.to(() => const PrivacySecurityScreen()),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context: context,
          title: 'Member Since',
          value: _formatDate(user.createdAt),
          icon: Icons.calendar_today_rounded,
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context: context,
          title: 'Last Login',
          value: _formatDate(user.lastLoginAt),
          icon: Icons.access_time_rounded,
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.orange[600]!],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
                subtitle: 'Change your profile information',
                iconGradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                ),
                onTap: () => Get.to(() => const EditProfileScreen()),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Manage your notifications',
                iconGradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                trailing: Obx(() => Switch.adaptive(
                      value: authController.notificationsEnabled.value,
                      onChanged: (value) {
                        authController.toggleNotifications(value);
                      },
                    )),
                onTap: () => Get.to(() => const NotificationsScreen()),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.security_rounded,
                title: 'Privacy & Security',
                subtitle: 'Manage your account security',
                iconGradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                onTap: () => Get.to(() => const PrivacySecurityScreen()),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.palette_rounded,
                title: 'Appearance',
                subtitle: 'Customize your app theme',
                iconGradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                trailing: Icon(
                  Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => _showThemeDialog(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'Change app language',
                iconGradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Get.locale?.languageCode.toUpperCase() ?? 'EN',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () => _showLanguageDialog(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.help_rounded,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                iconGradient: LinearGradient(
                  colors: [Colors.teal[400]!, Colors.teal[600]!],
                ),
                onTap: () => Get.to(() => const HelpSupportScreen()),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.info_rounded,
                title: 'About',
                subtitle: 'App version and information',
                iconGradient: LinearGradient(
                  colors: [Colors.indigo[400]!, Colors.indigo[600]!],
                ),
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Gradient? iconGradient,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: iconGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.grey[200],
        height: 1,
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_system_daydream),
              title: const Text('System'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                Get.updateLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Türkçe'),
              onTap: () {
                Get.updateLocale(const Locale('tr', 'TR'));
                Navigator.pop(context);
              },
            ),
            // Add more languages as needed
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Task Manager',
        applicationVersion: '1.0.0',
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 50,
          height: 50,
        ),
        children: const [
          Text(
            'A modern task management application built with Flutter and Firebase.',
          ),
          SizedBox(height: 16),
          Text(
            '© 2024 Task Manager. All rights reserved.',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';

    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 0) {
        return 'Just now';
      }

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
        }
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Date error';
    }
  }

  void _showSignOutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              authController.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
