import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_app/controllers/task_controller.dart';
import 'package:task_manager_app/models/task_model.dart';

class AddTaskScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TaskController _taskController = Get.find<TaskController>();
  final Rx<TaskPriority> _priority = TaskPriority.low.obs;
  final Rx<DateTime> _deadline = DateTime.now().obs;

  AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  _buildPriorityChip(context, 'Low', TaskPriority.low, Colors.green),
                  const SizedBox(width: 8),
                  _buildPriorityChip(context, 'Medium', TaskPriority.medium, Colors.orange),
                  const SizedBox(width: 8),
                  _buildPriorityChip(context, 'High', TaskPriority.high, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Deadline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Obx(
              () => Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    '${_deadline.value.day}/${_deadline.value.month}/${_deadline.value.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _addTask(context),
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    BuildContext context,
    String label,
    TaskPriority value,
    Color color,
  ) {
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: _priority.value == value,
        onSelected: (selected) => _priority.value = value,
        backgroundColor: color.withOpacity(0.1),
        selectedColor: color.withOpacity(0.2),
        labelStyle: TextStyle(
          color: _priority.value == value ? color : Colors.grey,
          fontWeight: _priority.value == value ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: color,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _deadline.value = picked;
    }
  }

  void _addTask(BuildContext context) {
    if (_titleController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority.value,
      deadline: _deadline.value,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    _taskController.addTask(task);
    Get.back();
  }
}
