import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          Obx(() => SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive push notifications'),
                value: authController.notificationsEnabled.value,
                onChanged: authController.toggleNotifications,
              )),
          const Divider(),
          ListTile(
            title: const Text('Task Reminders'),
            subtitle: const Text('Get notified about upcoming tasks'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement task reminders
              },
            ),
          ),
          ListTile(
            title: const Text('Due Date Alerts'),
            subtitle: const Text('Get notified when tasks are due'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement due date alerts
              },
            ),
          ),
        ],
      ),
    );
  }
}
