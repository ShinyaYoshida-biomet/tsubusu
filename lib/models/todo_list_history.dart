import 'todo.dart';
import 'todo_list_id.dart';

class TodoListHistory {
  final TodoListId id;
  final String title;
  final List<Todo> todos;
  final bool isLegacy;
  final int recencyScore;

  const TodoListHistory({
    required this.id,
    required this.title,
    required this.todos,
    required this.isLegacy,
    required this.recencyScore,
  });

  int get taskCount => todos.length;

  String get formatLabel => isLegacy ? 'Legacy' : 'Current';

  String get recencyLabel {
    if (recencyScore < 1000000000000) return 'Older history';
    final date = DateTime.fromMicrosecondsSinceEpoch(recencyScore).toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}
