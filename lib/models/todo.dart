class Todo {
  String text;
  bool isCompleted;
  final String id;
  final String? parentId;

  Todo({
    required this.text,
    required this.isCompleted,
    String? id,
    this.parentId,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Todo copyWith({
    String? text,
    bool? isCompleted,
    String? id,
    String? parentId,
    bool clearParentId = false,
  }) {
    return Todo(
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id,
      parentId: clearParentId ? null : parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'parentId': parentId,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'],
      parentId: json['parentId'] as String?,
    );
  }
}
