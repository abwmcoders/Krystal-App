import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krystal_app/features/tasks/presentation/provider/todos_provider.dart';

final pendingCounterProvider = Provider<int>((ref) {
  final todos = ref.watch(todosProvider);
  final now = DateTime.now();
  final pending = todos.where((todo) => !todo.completed && (todo.endAt == null || todo.endAt!.isAfter(now))).toList();
  return pending.length;
});

final completedCounterProvider = Provider<int>((ref) {
  final todos = ref.watch(todosProvider);
  final completed = todos.where((todo) => todo.completed).toList();
  return completed.length;
});

/// Reminder counter: count tasks whose end time has passed (overdue)
final remindersCounterProvider = Provider<int>((ref) {
  final todos = ref.watch(todosProvider);
  final now = DateTime.now();
  final reminders = todos.where((todo) => !todo.completed && todo.endAt != null && todo.endAt!.isBefore(now)).toList();
  return reminders.length;
});
