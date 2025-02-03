import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'settings/edit_profile_screen.dart';
import 'settings/notifications_screen.dart';
import 'settings/privacy_security_screen.dart';
import 'settings/help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showSignOutDialog(context, authController),
          ),
        ],
      ),
      body: Obx(
        () {
          final user = authController.userModel.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(context, user.photoUrl, user.displayName),
              const SizedBox(height: 24),
              _buildInfoCard(
                context,
                'Email',
                user.email,
                Icons.email_rounded,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Member Since',
                _formatDate(user.createdAt),
                Icons.calendar_today_rounded,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Last Login',
                _formatDate(user.lastLoginAt),
                Icons.access_time_rounded,
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String? photoUrl,
    String? displayName,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          displayName ?? 'User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
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
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            subtitle: 'Change your profile information',
            onTap: () => Get.to(() => const EditProfileScreen()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Manage your notifications',
            trailing: Obx(() => Switch(
                  value: Get.find<AuthController>().notificationsEnabled.value,
                  onChanged: (value) {
                    Get.find<AuthController>().toggleNotifications(value);
                  },
                )),
            onTap: () => Get.to(() => const NotificationsScreen()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_rounded,
            title: 'Privacy & Security',
            subtitle: 'Manage your account security',
            onTap: () => Get.to(() => const PrivacySecurityScreen()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.palette_rounded,
            title: 'Appearance',
            subtitle: 'Customize your app theme',
            trailing: Icon(
              Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () => _showThemeDialog(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'Change app language',
            trailing: Text(
              Get.locale?.languageCode.toUpperCase() ?? 'EN',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showLanguageDialog(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.help_rounded,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => Get.to(() => const HelpSupportScreen()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_rounded,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
          ElevatedButton(
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
