import '../domain/todo.dart';

/// A repository interface defining the operations for managing [Todo] items.
abstract class TodosRepository {
  Future<List<Todo>> getTodos();
  Future<void> deleteTodo(String id);
  Future<void> addTodo({required String title, required String description, DateTime? startAt, DateTime? endAt});
  Future<void> toggleTodo(String id);
  Future<void> updateTodo(Todo todo);
}
