import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              title: 'Account Security',
              subtitle: 'Manage your account security settings',
            ),
            _buildSecuritySection(context, authController),
            _buildHeader(
              context,
              title: 'Privacy',
              subtitle: 'Manage your privacy preferences',
            ),
            _buildPrivacySection(context),
            _buildHeader(
              context,
              title: 'Data & Storage',
              subtitle: 'Manage your data and storage settings',
            ),
            _buildDataSection(context),
            const SizedBox(height: 24),
            _buildDangerZone(context, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, AuthController authController) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.lock_reset_rounded,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => _showChangePasswordDialog(context, authController),
        ),
        _buildSettingsTile(
          context,
          icon: Icons.security_rounded,
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          trailing: Switch.adaptive(
            value: false, // TODO: Implement 2FA state
            onChanged: (value) {
              // TODO: Implement 2FA toggle
            },
          ),
        ),
        _buildSettingsTile(
          context,
          icon: Icons.devices_rounded,
          title: 'Active Sessions',
          subtitle: 'Manage devices & sessions',
          onTap: () {
            // TODO: Implement active sessions screen
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.visibility_rounded,
          title: 'Profile Visibility',
          subtitle: 'Control who can see your profile',
          onTap: () {
            // TODO: Implement profile visibility settings
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.block_rounded,
          title: 'Blocked Users',
          subtitle: 'Manage blocked users',
          onTap: () {
            // TODO: Implement blocked users screen
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.download_rounded,
          title: 'Download My Data',
          subtitle: 'Get a copy of your data',
          onTap: () {
            // TODO: Implement data download
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.storage_rounded,
          title: 'Data Usage',
          subtitle: 'Manage app data and cache',
          onTap: () {
            // TODO: Implement data usage screen
          },
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, AuthController authController) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showDeleteAccountDialog(context, authController),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Delete Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
              padding: const EdgeInsets.all(16),
            ),
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
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthController authController) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement password change
              Navigator.pop(context);
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
