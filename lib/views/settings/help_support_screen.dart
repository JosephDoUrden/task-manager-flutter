import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpHeader(context),
            _buildQuickHelp(context),
            _buildDivider(context),
            _buildFAQSection(context),
            _buildDivider(context),
            _buildContactSupport(context),
            _buildDivider(context),
            _buildResourcesSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpHeader(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final preferredHeight = screenHeight * 0.2; // 20% of screen height

    return Container(
      height: preferredHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help you?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find answers, get support, or contact us',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Help',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(context),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickHelpChip(
                context,
                icon: Icons.task_rounded,
                label: 'Tasks',
                onTap: () => _showHelpArticle(
                  context,
                  'Managing Tasks',
                  'Learn how to create, edit, and organize your tasks effectively.',
                ),
              ),
              _buildQuickHelpChip(
                context,
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () => _showHelpArticle(
                  context,
                  'Notification Settings',
                  'Configure your notification preferences and reminders.',
                ),
              ),
              _buildQuickHelpChip(
                context,
                icon: Icons.sync_rounded,
                label: 'Sync',
                onTap: () => _showHelpArticle(
                  context,
                  'Data Synchronization',
                  'Understand how task synchronization works across devices.',
                ),
              ),
              _buildQuickHelpChip(
                context,
                icon: Icons.security_rounded,
                label: 'Security',
                onTap: () => _showHelpArticle(
                  context,
                  'Account Security',
                  'Learn about security features and best practices.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for help',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      onChanged: (value) {
        // TODO: Implement help search functionality
      },
    );
  }

  Widget _buildQuickHelpChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        _buildFAQTile(
          context,
          question: 'How do I create a new task?',
          answer: 'To create a new task, tap the + button at the bottom of the screen. Fill in the task details and tap Save.',
        ),
        _buildFAQTile(
          context,
          question: 'Can I set recurring tasks?',
          answer: 'Yes! When creating or editing a task, you can set it to repeat daily, weekly, or monthly.',
        ),
        _buildFAQTile(
          context,
          question: 'How do I change my notification settings?',
          answer: 'Go to Settings > Notifications to customize your notification preferences.',
        ),
        _buildFAQTile(
          context,
          question: 'Is my data backed up?',
          answer: 'Yes, your data is automatically synced and backed up to your account.',
        ),
      ],
    );
  }

  Widget _buildFAQTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Support',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            context,
            icon: Icons.email_rounded,
            title: 'Email Support',
            subtitle: 'Get help via email',
            onTap: () => _launchEmail(),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            context,
            icon: Icons.chat_rounded,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            onTap: () {
              // TODO: Implement live chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: ListTile(
        onTap: onTap,
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
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resources',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildResourceChip(
                context,
                icon: Icons.book_rounded,
                label: 'User Guide',
                onTap: () {
                  // TODO: Open user guide
                },
              ),
              _buildResourceChip(
                context,
                icon: Icons.video_library_rounded,
                label: 'Video Tutorials',
                onTap: () {
                  // TODO: Open video tutorials
                },
              ),
              _buildResourceChip(
                context,
                icon: Icons.tips_and_updates_rounded,
                label: 'Tips & Tricks',
                onTap: () {
                  // TODO: Open tips and tricks
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }

  void _showHelpArticle(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@taskmanager.com',
      queryParameters: {
        'subject': 'Task Manager Support Request',
      },
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }
}
