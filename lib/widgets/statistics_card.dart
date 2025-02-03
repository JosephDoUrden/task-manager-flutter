import 'package:flutter/material.dart';
import '../models/task_model.dart';

class StatisticsCard extends StatelessWidget {
  final List<Task> tasks;
  final double completionRate;
  final List<Task> overdueTasks;
  final List<Task> todayTasks;

  const StatisticsCard({
    super.key,
    required this.tasks,
    required this.completionRate,
    required this.overdueTasks,
    required this.todayTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  'Total Tasks',
                  tasks.length.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Completion Rate',
                  '${(completionRate * 100).toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  'Due Today',
                  todayTasks.length.toString(),
                  Icons.today,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Overdue',
                  overdueTasks.length.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildPriorityDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDistribution() {
    final highPriority = tasks.where((task) => task.priority == TaskPriority.high).length;
    final mediumPriority = tasks.where((task) => task.priority == TaskPriority.medium).length;
    final lowPriority = tasks.where((task) => task.priority == TaskPriority.low).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildPriorityBar('High', highPriority, tasks.length, Colors.red),
        const SizedBox(height: 4),
        _buildPriorityBar('Medium', mediumPriority, tasks.length, Colors.orange),
        const SizedBox(height: 4),
        _buildPriorityBar('Low', lowPriority, tasks.length, Colors.green),
      ],
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            count.toString(),
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
