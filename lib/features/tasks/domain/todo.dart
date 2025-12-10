import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late bool completed;

  @HiveField(4)
  DateTime? startAt;

  @HiveField(5)
  DateTime? endAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    this.startAt,
    this.endAt,
  });
}
