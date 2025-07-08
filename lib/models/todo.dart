class Todo {
  String text;
  bool isCompleted;
  final String id;

  Todo({required this.text, required this.isCompleted})
      : id = DateTime.now().millisecondsSinceEpoch.toString();

  Todo._withId({required this.text, required this.isCompleted, required this.id});

  Todo copyWith({
    String? text,
    bool? isCompleted,
  }) {
    return Todo._withId(
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id,
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
    return Todo._withId(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'],
    );
  }
}