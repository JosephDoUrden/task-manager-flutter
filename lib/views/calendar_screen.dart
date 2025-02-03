import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskController taskController = Get.find<TaskController>();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final DateFormat _dateFormatter = DateFormat('MMMM d, y');

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getTasksForDay(DateTime day) {
    return taskController.tasks.where((task) {
      return isSameDay(task.deadline, day);
    }).toList();
  }

  Map<DateTime, int> _getTaskCountForMonth() {
    Map<DateTime, int> taskCounts = {};
    for (var task in taskController.tasks) {
      final date = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      taskCounts[date] = (taskCounts[date] ?? 0) + 1;
    }
    return taskCounts;
  }

  void _showAddTaskBottomSheet(BuildContext context, [DateTime? selectedDate]) {
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
                initialDate: selectedDate,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
              });
            },
          ),
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(Icons.calendar_view_month),
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Month'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getTasksForDay,
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              final tasksForDay = _getTasksForDay(_selectedDay!);
              if (tasksForDay.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No tasks for ${_dateFormatter.format(_selectedDay!)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTaskBottomSheet(context, _selectedDay),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Task'),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateFormatter.format(_selectedDay!),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${tasksForDay.length} task${tasksForDay.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasksForDay.length,
                      itemBuilder: (context, index) {
                        final task = tasksForDay[index];
                        return TaskCard(
                          task: task,
                          onToggleCompletion: (task) => taskController.toggleTaskCompletion(task),
                          onDelete: (task) => taskController.deleteTask(task.id!),
                          onEdit: (task) => taskController.updateTask(task),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskBottomSheet(context, _selectedDay),
        child: const Icon(Icons.add),
      ),
    );
  }
}
