import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_repository.dart';
import '../../data/todos_repository.dart';

/// Provides a [HiveRepository] instance for managing local database operations.
final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return HiveRepository();
});
