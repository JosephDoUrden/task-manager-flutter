import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class CacheService {
  static const String tasksBoxName = 'tasks';
  static const String userBoxName = 'user';

  Future<Box<dynamic>> _openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  // Cache tasks
  Future<void> cacheTasks(List<Map<String, dynamic>> tasks) async {
    final box = await _openBox(tasksBoxName);
    await box.put('cached_tasks', tasks);
    await box.put('last_cached', DateTime.now().toIso8601String());
  }

  // Get cached tasks
  Future<List<Map<String, dynamic>>?> getCachedTasks() async {
    final box = await _openBox(tasksBoxName);
    final tasks = box.get('cached_tasks');
    return tasks != null ? List<Map<String, dynamic>>.from(tasks) : null;
  }

  // Get last cache time
  Future<DateTime?> getLastCacheTime() async {
    final box = await _openBox(tasksBoxName);
    final lastCached = box.get('last_cached');
    return lastCached != null ? DateTime.parse(lastCached) : null;
  }

  // Cache user data
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    final box = await _openBox(userBoxName);
    await box.put('cached_user', userData);
  }

  // Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData() async {
    final box = await _openBox(userBoxName);
    final userData = box.get('cached_user');
    return userData != null ? Map<String, dynamic>.from(userData) : null;
  }

  // Clear user cache
  Future<void> clearUserCache() async {
    final box = await _openBox(userBoxName);
    await box.clear();
  }

  // Clear task cache
  Future<void> clearTaskCache() async {
    final box = await _openBox(tasksBoxName);
    await box.clear();
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await clearUserCache();
    await clearTaskCache();
  }

  // Check if cache is expired (older than 1 hour)
  Future<bool> isCacheExpired() async {
    final lastCacheTime = await getLastCacheTime();
    if (lastCacheTime == null) return true;

    final difference = DateTime.now().difference(lastCacheTime);
    return difference.inHours >= 1;
  }
}
