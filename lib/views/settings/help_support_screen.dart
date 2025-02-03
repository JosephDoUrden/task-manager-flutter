import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQs'),
            onTap: () {
              // TODO: Implement FAQs
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact Support'),
            onTap: () => _launchUrl('mailto:support@example.com'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Implement terms of service
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Implement privacy policy
            },
          ),
        ],
      ),
    );
  }
}
