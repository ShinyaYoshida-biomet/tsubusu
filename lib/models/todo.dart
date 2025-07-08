class Todo {
  String text;
  bool isCompleted;
  final String id;

  Todo({required this.text, required this.isCompleted, String? id})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Todo copyWith({
    String? text,
    bool? isCompleted,
    String? id,
  }) {
    return Todo(
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'],
    );
  }
}