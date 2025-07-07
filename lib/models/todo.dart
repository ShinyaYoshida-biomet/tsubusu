class Todo {
  String text;
  bool isCompleted;
  final String id;

  Todo({required this.text, required this.isCompleted})
      : id = DateTime.now().millisecondsSinceEpoch.toString();

  Todo copyWith({
    String? text,
    bool? isCompleted,
  }) {
    return Todo(
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}