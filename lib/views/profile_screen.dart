import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

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
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Implement edit profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_rounded),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Implement notifications settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('Privacy & Security'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Implement privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_rounded),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Implement help & support
            },
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
