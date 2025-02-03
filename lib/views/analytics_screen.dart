import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';

class AnalyticsScreen extends StatelessWidget {
  final TaskController taskController = Get.find<TaskController>();

  AnalyticsScreen({super.key});

  Map<TaskPriority, int> _getPriorityDistribution() {
    Map<TaskPriority, int> distribution = {};
    for (var task in taskController.tasks) {
      distribution[task.priority] = (distribution[task.priority] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _getWeeklyTaskDistribution() {
    Map<String, int> weeklyTasks = {};
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = DateFormat('EEE').format(day);
      final count = taskController.tasks.where((task) => isSameDay(task.deadline, day)).length;
      weeklyTasks[dayStr] = count;
    }
    return weeklyTasks;
  }

  double _getCompletionRate() {
    if (taskController.tasks.isEmpty) return 0;
    final completedTasks = taskController.tasks.where((task) => task.isCompleted).length;
    return completedTasks / taskController.tasks.length;
  }

  Duration _getAverageCompletionTime() {
    final completedTasks = taskController.tasks.where((task) => task.isCompleted && task.completedAt != null).toList();

    if (completedTasks.isEmpty) return Duration.zero;

    int totalMinutes = 0;
    for (var task in completedTasks) {
      final duration = task.completedAt!.difference(task.createdAt);
      totalMinutes += duration.inMinutes;
    }
    return Duration(minutes: totalMinutes ~/ completedTasks.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskController.fetchTasks(),
          ),
        ],
      ),
      body: Obx(() {
        if (taskController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskController.tasks.isEmpty) {
          return const Center(
            child: Text('No tasks available for analysis'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(),
              const SizedBox(height: 16),
              _buildPriorityChart(),
              const SizedBox(height: 16),
              _buildWeeklyDistributionChart(),
              const SizedBox(height: 16),
              _buildProductivityInsights(),
              const SizedBox(height: 16),
              _buildTaskStatusBreakdown(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverviewCard() {
    final completionRate = _getCompletionRate();
    final avgCompletionTime = _getAverageCompletionTime();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Tasks',
                  taskController.tasks.length.toString(),
                  Icons.task,
                ),
                _buildStatItem(
                  'Completion Rate',
                  '${(completionRate * 100).toStringAsFixed(1)}%',
                  Icons.done_all,
                ),
                _buildStatItem(
                  'Avg. Time',
                  '${avgCompletionTime.inHours}h ${avgCompletionTime.inMinutes % 60}m',
                  Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChart() {
    final distribution = _getPriorityDistribution();
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: distribution.entries.map((entry) {
                    final percentage = (entry.value / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      color: _getPriorityColor(TaskPriority.values[entry.key.index]),
                      value: entry.value.toDouble(),
                      title: '$percentage%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: TaskPriority.values.map((priority) {
                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(priority.toString().split('.').last),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyDistributionChart() {
    final weeklyTasks = _getWeeklyTaskDistribution();
    final maxTasks = weeklyTasks.values.fold(0, (max, count) => count > max ? count : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxTasks.toDouble(),
                  barGroups: weeklyTasks.entries.map((entry) {
                    return BarChartGroupData(
                      x: weeklyTasks.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Theme.of(Get.context!).primaryColor,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(weeklyTasks.keys.toList()[value.toInt()]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productivity Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Most Productive Day',
              _getMostProductiveDay(),
              Icons.star,
            ),
            const Divider(),
            _buildInsightItem(
              'Tasks Due Today',
              taskController.tasksForToday.length.toString(),
              Icons.today,
            ),
            const Divider(),
            _buildInsightItem(
              'Overdue Tasks',
              taskController.overdueTasks.length.toString(),
              Icons.warning,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Status Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getCompletionRate(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(Get.context!).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${taskController.completedTasks.length} Completed',
                  style: const TextStyle(color: Colors.green),
                ),
                Text(
                  '${taskController.pendingTasks.length} Pending',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getMostProductiveDay() {
    final weeklyTasks = _getWeeklyTaskDistribution();
    final maxTasks = weeklyTasks.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${maxTasks.key} (${maxTasks.value} tasks)';
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
