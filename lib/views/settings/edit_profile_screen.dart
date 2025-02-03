import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _displayNameController.text = _authController.userModel.value?.displayName ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authController.updateProfile(
          displayName: _displayNameController.text,
        );
        Get.back();
      } catch (e) {
        // Error is already handled in the controller
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Obx(() {
        final user = _authController.userModel.value;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a display name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
