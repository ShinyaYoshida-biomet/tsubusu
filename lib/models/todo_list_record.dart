import 'todo_list_id.dart';

class TodoListRecord {
  final TodoListId id;
  final String title;

  const TodoListRecord({required this.id, required this.title});

  TodoListRecord copyWith({TodoListId? id, String? title}) {
    return TodoListRecord(id: id ?? this.id, title: title ?? this.title);
  }

  Map<String, dynamic> toJson() => {'id': id.value, 'title': title};

  factory TodoListRecord.fromJson(Map<String, dynamic> json) {
    return TodoListRecord(
      id: TodoListId.fromValue(json['id'] as String),
      title:
          (json['title'] as String?)?.trim().isNotEmpty == true
              ? (json['title'] as String).trim()
              : 'tsubusu',
    );
  }
}
