import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';
import '../widgets/statistics_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../views/calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  final TaskController taskController = Get.put(TaskController());
  final RxString currentFilter = 'all'.obs;
  final RxString currentSort = 'deadline'.obs;

  HomeScreen({super.key});

  List<Task> _getFilteredAndSortedTasks() {
    List<Task> filteredTasks = [];

    // Apply filters
    switch (currentFilter.value) {
      case 'pending':
        filteredTasks = taskController.pendingTasks;
        break;
      case 'completed':
        filteredTasks = taskController.completedTasks;
        break;
      case 'all':
      default:
        filteredTasks = taskController.tasks;
    }

    // Create a new list to avoid modifying the original
    List<Task> sortedTasks = List.from(filteredTasks);

    // Apply sorting
    switch (currentSort.value) {
      case 'priority':
        sortedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'deadline':
        sortedTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'title':
        sortedTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'created':
        sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sortedTasks;
  }

  String _getFilterTitle() {
    switch (currentFilter.value) {
      case 'pending':
        return 'Pending Tasks';
      case 'completed':
        return 'Completed Tasks';
      case 'all':
      default:
        return 'All Tasks';
    }
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TaskForm(
                onSubmit: (task) {
                  taskController.addTask(task);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTaskBottomSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TaskForm(
                task: task,
                onSubmit: (updatedTask) {
                  taskController.updateTask(updatedTask);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Get.to(() => const CalendarScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement export functionality
            },
          ),
        ],
      ),
      body: Obx(
        () => taskController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: StatisticsCard(
                      tasks: taskController.tasks,
                      completionRate: taskController.completionRate,
                      overdueTasks: taskController.overdueTasks,
                      todayTasks: taskController.tasksForToday,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                                _getFilterTitle(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          Row(
                            children: [
                              // Filter Button
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.filter_list),
                                onSelected: (value) {
                                  currentFilter.value = value;
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'all',
                                    child: Row(
                                      children: [
                                        Icon(Icons.list),
                                        SizedBox(width: 8),
                                        Text('All Tasks'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'pending',
                                    child: Row(
                                      children: [
                                        Icon(Icons.pending),
                                        SizedBox(width: 8),
                                        Text('Pending Tasks'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'completed',
                                    child: Row(
                                      children: [
                                        Icon(Icons.done_all),
                                        SizedBox(width: 8),
                                        Text('Completed Tasks'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Sort Button
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.sort),
                                onSelected: (value) {
                                  currentSort.value = value;
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'deadline',
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today),
                                        SizedBox(width: 8),
                                        Text('Sort by Deadline'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'priority',
                                    child: Row(
                                      children: [
                                        Icon(Icons.priority_high),
                                        SizedBox(width: 8),
                                        Text('Sort by Priority'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'title',
                                    child: Row(
                                      children: [
                                        Icon(Icons.sort_by_alpha),
                                        SizedBox(width: 8),
                                        Text('Sort by Title'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'created',
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time),
                                        SizedBox(width: 8),
                                        Text('Sort by Created Date'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() => SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final filteredTasks = _getFilteredAndSortedTasks();
                            final task = filteredTasks[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: TaskCard(
                                    task: task,
                                    onTap: () => _showEditTaskBottomSheet(context, task),
                                    onToggleCompletion: (task) => taskController.toggleTaskCompletion(task),
                                    onDelete: (task) => taskController.deleteTask(task.id!),
                                    onEdit: (task) => _showEditTaskBottomSheet(context, task),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _getFilteredAndSortedTasks().length,
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
