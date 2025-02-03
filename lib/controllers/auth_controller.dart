import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../controllers/task_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool notificationsEnabled = true.obs;

  User? get currentUser => firebaseUser.value;

  @override
  void onInit() {
    debugPrint('Initializing AuthController...');
    super.onInit();
    try {
      firebaseUser.bindStream(_authService.authStateChanges);
      debugPrint('Successfully bound to auth state changes stream');
      ever(firebaseUser, _setInitialScreen);
      debugPrint('Set up auth state listener');
    } catch (e, stackTrace) {
      debugPrint('Error in AuthController initialization: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _setInitialScreen(User? user) async {
    debugPrint('Auth state changed. User: ${user?.email ?? 'null'}');
    if (user == null) {
      debugPrint('No user logged in, navigating to login screen');
      userModel.value = null;
      Get.offAllNamed('/login');
    } else {
      try {
        debugPrint('User logged in, fetching user data...');
        isLoading.value = true;
        userModel.value = await _authService.getUserData(user.uid);
        debugPrint('User data fetched successfully, navigating to home screen');
        Get.offAllNamed('/home');
      } catch (e, stackTrace) {
        debugPrint('Error fetching user data: $e');
        debugPrint('Stack trace: $stackTrace');
        Get.snackbar(
          'Error',
          'Failed to load user data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 5),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    debugPrint('Attempting to sign in user: $email');
    try {
      isLoading.value = true;
      userModel.value = await _authService.signInWithEmailAndPassword(email, password);
      debugPrint('Sign in successful for user: $email');
    } catch (e, stackTrace) {
      debugPrint('Sign in error: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Sign In Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String? displayName) async {
    debugPrint('Attempting to register new user: $email');
    try {
      isLoading.value = true;
      userModel.value = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      debugPrint('Registration successful for user: $email');
    } catch (e, stackTrace) {
      debugPrint('Registration error: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    debugPrint('Attempting Google sign in');
    try {
      isLoading.value = true;
      userModel.value = await _authService.signInWithGoogle();
      debugPrint('Google sign in successful');
    } catch (e, stackTrace) {
      debugPrint('Google sign in error: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Google Sign In Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Clear all user data
      Get.find<TaskController>().clearTasks();
      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    debugPrint('Attempting to send password reset email to: $email');
    try {
      isLoading.value = true;
      await _authService.resetPassword(email);
      debugPrint('Password reset email sent successfully');
      Get.snackbar(
        'Success',
        'Password reset email sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 5),
      );
    } catch (e, stackTrace) {
      debugPrint('Password reset error: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Password Reset Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    debugPrint('Attempting to update user profile');
    try {
      isLoading.value = true;
      userModel.value = await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      debugPrint('Profile updated successfully');
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 5),
      );
    } catch (e, stackTrace) {
      debugPrint('Profile update error: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Profile Update Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // Implement notification toggle logic
  }
}
