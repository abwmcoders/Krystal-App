import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/todo.dart';
import 'todos_repository.dart';

/// A concrete implementation of the [TodosRepository] interface
/// using the [Hive] database.
class HiveRepository implements TodosRepository {
  static const String boxName = 'todos_box';
  late Box<Todo> _todosBox;

  HiveRepository() {
    _initBox();
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      _todosBox = await Hive.openBox<Todo>(boxName);
    } else {
      _todosBox = Hive.box<Todo>(boxName);
    }
  }

  Future<Box<Todo>> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      _todosBox = await Hive.openBox<Todo>(boxName);
    }
    return _todosBox;
  }

  @override
  Future<void> addTodo({required String title, required String description, DateTime? startAt, DateTime? endAt}) async {
    try {
      final box = await _getBox();
      const uuid = Uuid();
      final newTodo = Todo(
        id: uuid.v4(),
        title: title,
        description: description,
        completed: false,
        startAt: startAt,
        endAt: endAt,
      );
      await box.add(newTodo);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    final box = await _getBox();
    dynamic keyToDelete;

    for (final key in box.keys) {
      final todo = box.get(key);
      if (todo?.id == id) {
        keyToDelete = key;
        break;
      }
    }

    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
  }

  @override
  Future<void> toggleTodo(String id) async {
    final box = await _getBox();

    for (final key in box.keys) {
      final todo = box.get(key);
      if (todo?.id == id) {
        todo?.completed = !todo.completed;
        await box.put(key, todo!);
        break;
      }
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final box = await _getBox();
    dynamic foundKey;

    for (final key in box.keys) {
      final t = box.get(key);
      if (t?.id == todo.id) {
        foundKey = key;
        break;
      }
    }

    if (foundKey != null) {
      await box.put(foundKey, todo);
    }
  }

  @override
  Future<List<Todo>> getTodos() async {
    final box = await _getBox();
    final todos = box.values.toList();
    // Note: Hive values don't include keys; we can't sort by key easily here
    return todos.reversed.toList();
  }
}
