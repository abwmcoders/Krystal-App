import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/todos_repository.dart';
import '../../domain/todo.dart';
import 'loading_provider.dart';
import 'todos_repository_provider.dart';

enum TodoFilter { all, completed, pending, reminders }

/// The provider for managing the currently selected [TodoFilter].
final selectedFilterTodoProvider = StateProvider<TodoFilter>((ref) {
  return TodoFilter.all;
});

/// Provides a filtered list of [Todo] items based on the selected [TodoFilter].
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todoFilter = ref.watch(selectedFilterTodoProvider);
  final todos = ref.watch(todosProvider);

  // Search query provider: used to reorder / filter results based on user input
  final searchQuery = ref.watch(searchQueryProvider);

  // Apply the base filter first, including reminder logic (overdue tasks)
  final now = DateTime.now();
  List<Todo> baseList = switch (todoFilter) {
    TodoFilter.all => todos,
    TodoFilter.completed => todos.where((todo) => todo.completed).toList(),
    TodoFilter.pending =>
      todos.where((todo) => !todo.completed && (todo.endAt == null || todo.endAt!.isAfter(now))).toList(),
    TodoFilter.reminders =>
      todos.where((todo) => !todo.completed && todo.endAt != null && todo.endAt!.isBefore(now)).toList(),
  };

  // If there's no search query, return the base filtered list
  final query = searchQuery.trim().toLowerCase();
  if (query.isEmpty) return baseList;

  // Compute a simple relevance score for each todo based on search words
  final words = query.split(RegExp(r"\s+")).where((w) => w.isNotEmpty).toList();

  // Filter to items that match ALL words (AND semantics). This hides non-matching items.
  final scored = <MapEntry<Todo, int>>[];
  for (final todo in baseList) {
    final desc = todo.description.toLowerCase();

    // require all words to be present
    final matchesAll = words.every((w) => desc.contains(w));
    if (!matchesAll) continue; // hide non-matching items

    int score = 0;
    for (final w in words) {
      if (desc == w) {
        score += 100; // exact match
      } else if (desc.startsWith(w)) {
        score += 50;
      } else if (desc.contains(w)) {
        score += 20;
      }
    }
    scored.add(MapEntry(todo, score));
  }

  // Sort by score desc
  scored.sort((a, b) => b.value.compareTo(a.value));

  // Return only matching todos ordered by relevance
  return scored.map((e) => e.key).toList();
});

/// Provider holding the current search query entered by the user.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// The provider for managing the list of [Todo] items.
final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) {
  final todosRepository = ref.watch(todosRepositoryProvider);
  return TodosNotifier(todosRepository: todosRepository, ref: ref);
});

class TodosNotifier extends StateNotifier<List<Todo>> {
  final TodosRepository todosRepository;
  final Ref ref;

  TodosNotifier({required this.todosRepository, required this.ref}) : super([]);

  Future<void> addTodo({required String title, required String description, DateTime? startAt, DateTime? endAt}) async {
    try {
      ref.read(createLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      // Simulate network delay (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      await todosRepository.addTodo(title: title, description: description, startAt: startAt, endAt: endAt);
      state = await todosRepository.getTodos();
      ref.read(successMessageProvider.notifier).state = 'Task created successfully!';
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Failed to create task: $e';
    } finally {
      ref.read(createLoadingProvider.notifier).state = false;
      // Clear success message after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      ref.read(successMessageProvider.notifier).state = null;
    }
  }

  Future<void> toggleTodo(String id) async {
    try {
      ref.read(toggleLoadingProvider.notifier).state = id;
      ref.read(errorMessageProvider.notifier).state = null;

      // Simulate network delay (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      await todosRepository.toggleTodo(id);
      state = await todosRepository.getTodos();
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Failed to update task: $e';
    } finally {
      ref.read(toggleLoadingProvider.notifier).state = null;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      ref.read(deleteLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      // Simulate network delay (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      await todosRepository.deleteTodo(id);
      state = await todosRepository.getTodos();
      ref.read(successMessageProvider.notifier).state = 'Task deleted successfully!';
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Failed to delete task: $e';
    } finally {
      ref.read(deleteLoadingProvider.notifier).state = false;
      // Clear success message after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      ref.read(successMessageProvider.notifier).state = null;
    }
  }

  Future<void> editTodo(Todo todo) async {
    try {
      ref.read(editLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      // Simulate network delay (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      await todosRepository.updateTodo(todo);
      state = await todosRepository.getTodos();
      ref.read(successMessageProvider.notifier).state = 'Task updated successfully!';
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Failed to update task: $e';
    } finally {
      ref.read(editLoadingProvider.notifier).state = false;
      // Clear success message after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      ref.read(successMessageProvider.notifier).state = null;
    }
  }

  Future<void> loadTodos() async {
    try {
      state = await todosRepository.getTodos();
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Failed to load tasks: $e';
    }
  }
}

/// The provider for managing the new [Todo] description.
final newTodoProvider = StateProvider<String>((ref) {
  return '';
});
