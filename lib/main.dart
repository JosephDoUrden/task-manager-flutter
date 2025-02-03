import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'views/main_screen.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/add_task_screen.dart';
import 'views/calendar_screen.dart';
import 'views/analytics_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/task_controller.dart';

Future<void> initializeFirebase() async {
  try {
    debugPrint('Attempting to initialize Firebase...');
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully with app: ${app.name}');
    return;
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized, getting existing instance...');
      Firebase.app();
      debugPrint('Successfully retrieved existing Firebase instance');
      return;
    }
    debugPrint('Unexpected Firebase initialization error: $e');
    rethrow;
  }
}

void main() async {
  debugPrint('Starting application initialization...');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Flutter binding initialized');

    // Initialize Firebase
    await initializeFirebase();

    // Initialize Hive
    try {
      debugPrint('Initializing Hive...');
      await Hive.initFlutter();
      debugPrint('Hive initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Hive initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    debugPrint('Running main app...');
    runApp(const TaskManagerApp());
  } catch (e, stackTrace) {
    debugPrint('Fatal error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building TaskManagerApp widget');
    try {
      // Initialize GetX controllers
      debugPrint('Initializing Controllers...');
      Get.put(AuthController(), permanent: true);
      Get.put(TaskController(), permanent: true);
      debugPrint('Controllers initialized successfully');

      return GetMaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        defaultTransition: Transition.fade,
        getPages: [
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/register', page: () => RegisterScreen()),
          GetPage(name: '/home', page: () => MainScreen()),
          GetPage(name: '/add-task', page: () => AddTaskScreen()),
          GetPage(name: '/calendar', page: () => const CalendarScreen()),
          GetPage(name: '/analytics', page: () => AnalyticsScreen()),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('Error building TaskManagerApp: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
