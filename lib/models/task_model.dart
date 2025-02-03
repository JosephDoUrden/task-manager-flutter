import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

class Task {
  String? id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime? completedAt;
  final TaskPriority priority;
  DateTime createdAt;
  String? notes;
  Color? color;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
    this.completedAt,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.notes,
    this.color,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Task to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'color': color?.value,
    };
  }

  // Create Task from Map
  factory Task.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Task(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: map['deadline'] is Timestamp ? (map['deadline'] as Timestamp).toDate() : DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] is Timestamp ? (map['completedAt'] as Timestamp).toDate() : DateTime.parse(map['completedAt']))
          : null,
      priority: TaskPriority.values[map['priority'] ?? TaskPriority.medium.index],
      createdAt: DateTime.parse(map['createdAt']),
      notes: map['notes'],
      color: map['color'] != null ? Color(map['color']) : null,
    );
  }

  // Copy with method for immutability
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedAt,
    TaskPriority? priority,
    DateTime? createdAt,
    String? notes,
    Color? color,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, deadline: $deadline, priority: $priority, isCompleted: $isCompleted}';
  }
}
