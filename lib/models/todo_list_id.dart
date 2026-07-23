/// A stable identifier for a logical todo list.
///
/// This deliberately has no relationship to an operating-system window. A
/// desktop window is only one possible way to present a list.
class TodoListId {
  final String value;

  const TodoListId._(this.value);

  factory TodoListId.fromValue(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', 'List ID cannot be empty');
    }
    return TodoListId._(value);
  }

  factory TodoListId.create() {
    return TodoListId._('list_${DateTime.now().microsecondsSinceEpoch}');
  }

  /// Creates the deterministic list ID used when importing pre-#31 data.
  factory TodoListId.fromLegacyWindowId(String legacyWindowId) {
    return TodoListId._('legacy_$legacyWindowId');
  }

  @override
  bool operator ==(Object other) => other is TodoListId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
