import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  final NavigationController navigationController = Get.put(NavigationController());

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: [
            HomeScreen(),
            const CalendarScreen(),
            AnalyticsScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNav(
          currentIndex: navigationController.currentIndex.value,
          onTap: navigationController.changePage,
        ),
      ),
    );
  }
}
