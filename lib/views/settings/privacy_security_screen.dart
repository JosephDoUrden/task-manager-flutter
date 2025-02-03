import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              // TODO: Implement change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Two-Factor Authentication'),
            onTap: () {
              // TODO: Implement 2FA
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            textColor: Colors.red,
            onTap: () {
              // TODO: Implement account deletion
            },
          ),
        ],
      ),
    );
  }
}
