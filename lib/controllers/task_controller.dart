import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/cache_service.dart';
import 'auth_controller.dart';

class TaskController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final CacheService _cacheService = CacheService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> completedTasks = <Task>[].obs;
  final RxList<Task> pendingTasks = <Task>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    ever(_authController.firebaseUser, (user) {
      if (user == null) {
        // User logged out, clear all tasks
        clearTasks();
      } else {
        // User logged in, fetch their tasks
        fetchTasks();
      }
    });
  }

  void _showError(String message) {
    // Only show snackbar if GetX context is ready
    if (Get.context != null && Get.isSnackbarOpen != true) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } else {
      debugPrint('Error: $message');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      isLoading.value = true;

      final userId = _authController.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _firestore.collection('users').doc(userId).collection('tasks').add(task.toMap());

      final newTask = task.copyWith(id: docRef.id);
      tasks.add(newTask);
      _updateTaskLists(); // Update lists after adding

      Get.back(); // Return to previous screen

      if (Get.context != null) {
        Get.snackbar(
          'Success',
          'Task added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      _showError('Failed to add task: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;

      final userId = _authController.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore.collection('users').doc(userId).collection('tasks').get();

      tasks.value = snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
      _updateTaskLists(); // Make sure lists are updated after fetching
    } catch (e) {
      _showError('Failed to fetch tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load all tasks
  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      // Check cache first
      final isCacheExpired = await _cacheService.isCacheExpired();
      final cachedTasks = await _cacheService.getCachedTasks();

      if (!isCacheExpired && cachedTasks != null) {
        tasks.value = cachedTasks.map((map) => Task.fromMap(map)).toList();
      } else {
        // Load from Firebase
        final userId = _authController.currentUser?.uid;
        if (userId != null) {
          final snapshot = await _firestore.collection('users').doc(userId).collection('tasks').get();

          final tasksList = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();

          tasks.value = tasksList;

          // Update cache
          await _cacheService.cacheTasks(
            tasksList.map((task) => task.toMap()).toList(),
          );
        }
      }
      _updateTaskLists();
    } catch (e) {
      _showError('Failed to load tasks: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _firestore.collection('users').doc(userId).collection('tasks').doc(task.id).update(task.toMap());

      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        _updateTaskLists();

        // Update cache
        await _cacheService.cacheTasks(
          tasks.map((task) => task.toMap()).toList(),
        );

        if (Get.context != null) {
          Get.snackbar(
            'Success',
            'Task updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900],
          );
        }
      }
    } catch (e) {
      _showError('Failed to update task: ${e.toString()}');
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _firestore.collection('users').doc(userId).collection('tasks').doc(id).delete();

      tasks.removeWhere((task) => task.id == id);
      _updateTaskLists();

      // Update cache
      await _cacheService.cacheTasks(
        tasks.map((task) => task.toMap()).toList(),
      );

      if (Get.context != null) {
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      _showError('Failed to delete task: ${e.toString()}');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await updateTask(updatedTask);
  }

  // Get tasks by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final snapshot =
          await _firestore.collection('users').doc(userId).collection('tasks').where('priority', isEqualTo: priority.index).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      _showError('Failed to get tasks by priority: ${e.toString()}');
      return [];
    }
  }

  // Get tasks by deadline
  Future<List<Task>> getTasksByDeadline(DateTime date) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('deadline', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('deadline', isLessThan: endOfDay.toIso8601String())
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      _showError('Failed to get tasks by deadline: ${e.toString()}');
      return [];
    }
  }

  // Update task lists
  void _updateTaskLists() {
    completedTasks.value = tasks.where((task) => task.isCompleted).toList();
    pendingTasks.value = tasks.where((task) => !task.isCompleted).toList();
  }

  // Get completion rate
  double get completionRate {
    if (tasks.isEmpty) return 0.0;
    return completedTasks.length / tasks.length;
  }

  // Get tasks due today
  List<Task> get tasksForToday {
    final now = DateTime.now();
    return tasks.where((task) {
      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      final today = DateTime(now.year, now.month, now.day);
      return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
    }).toList();
  }

  // Get overdue tasks
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return tasks.where((task) {
      return task.deadline.isBefore(now) && !task.isCompleted;
    }).toList();
  }

  // Clear cache
  Future<void> clearCache() async {
    await _cacheService.clearTaskCache();
  }

  void clearTasks() {
    tasks.clear();
    completedTasks.clear();
    pendingTasks.clear();
    clearCache(); // Clear the cached tasks as well
  }
}
