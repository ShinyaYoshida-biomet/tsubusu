import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../models/todo_list_id.dart';
import '../../models/todo_list_record.dart';
import '../../services/window_registry_service.dart';
import '../../services/todo_list_service.dart';
import '../../services/todo_list_catalog_service.dart';
import '../../services/window_manager.dart';
import '../organisms/app_header.dart';
import '../organisms/todo_list.dart';
import '../molecules/settings_dialog.dart';
import '../molecules/task_history_dialog.dart';

class TodoPage extends StatefulWidget {
  final WindowController? windowController;
  final TodoListId? initialListId;

  const TodoPage({super.key, this.windowController, this.initialListId});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  TodoListService? _todoService;
  String _windowTitle = 'Tsubusu';
  TodoListId? _listId;
  final _catalog = TodoListCatalogService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWindow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      _todoService?.refresh();
    }
  }

  Future<void> _initializeWindow() async {
    final lists = await _catalog.loadLists();
    TodoListRecord? selectedList;
    if (widget.initialListId != null) {
      for (final list in lists) {
        if (list.id == widget.initialListId) selectedList = list;
      }
    } else {
      final lastActiveListId = await _catalog.loadLastActiveListId();
      if (lastActiveListId != null &&
          lists.any((list) => list.id == lastActiveListId) &&
          await _catalog.hasTodos(lastActiveListId)) {
        selectedList = lists.firstWhere((list) => list.id == lastActiveListId);
      }
    }
    selectedList ??= await _catalog.mostRecentNonEmptyList(lists);
    if (selectedList == null && WindowManager.supportsWindowManagement) {
      final openListIds = await WindowRegistryService.getOpenListIds();
      for (final list in lists) {
        if (openListIds.contains(list.id.value)) {
          selectedList ??= list;
        }
      }
    }
    selectedList ??= await _catalog.ensureDefaultList();
    _listId = selectedList.id;
    _windowTitle = selectedList.title;

    // The main window is the active-list source for both Flutter and native
    // App Intents. iOS has no desktop window-management branch, so this must
    // also run during a normal mobile launch.
    if (widget.windowController == null) {
      await _catalog.markListActive(_listId!);
    }

    if (WindowManager.supportsWindowManagement) {
      await WindowRegistryService.registerOpenList(_listId!.value);
      if (widget.windowController != null) {
        await widget.windowController!.setFrameAutosaveName(
          'tsubusu_${_listId!.value}',
        );
      } else {
        WindowManager.registerMainWindowHandlers(onNewWindow: _createNewWindow);
      }
    }

    final todoService = TodoListService(_listId!);
    _todoService = todoService;
    await todoService.ready;

    if (!mounted) {
      await _removeFromOpenWindows();
      return;
    }

    if (WindowManager.supportsWindowManagement) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.windowController != null) {
          widget.windowController!.setTitle(_windowTitle);
        } else {
          WindowManager.updateWindowTitle(_windowTitle);
        }
      });
    }

    setState(() {
      _isInitialized = true;
    });

    if (widget.windowController == null &&
        WindowManager.supportsWindowManagement) {
      await _restoreAdditionalWindows();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeFromOpenWindows();
    _controller.dispose();
    _focusNode.dispose();
    _todoService?.dispose();
    super.dispose();
  }

  Future<void> _removeFromOpenWindows() async {
    if (_listId != null && widget.windowController != null) {
      await WindowRegistryService.unregisterOpenList(_listId!.value);
    }
  }

  Future<void> _restoreAdditionalWindows() async {
    final openListIds = await WindowRegistryService.getOpenListIds();
    final currentListId = _listId!.value;
    for (final listId in openListIds.where((id) => id != currentListId)) {
      final lists = await _catalog.loadLists();
      final matching = lists.where((list) => list.id.value == listId);
      if (matching.isEmpty) continue;
      await WindowManager.createWindow(
        listId: listId,
        title: matching.first.title,
      );
    }
  }

  Future<void> _createNewWindow() async {
    final newList = await _catalog.createList();
    await _catalog.markListActive(newList.id);
    await WindowRegistryService.registerOpenList(newList.id.value);
    await WindowManager.createWindow(
      listId: newList.id.value,
      title: newList.title,
    );
  }

  Future<void> _switchList(TodoListId listId) async {
    if (_listId == listId) return;
    final lists = await _catalog.loadLists();
    final selected = lists.where((list) => list.id == listId).firstOrNull;
    if (selected == null || !mounted) return;

    final previousListId = _listId;
    final previousService = _todoService;
    if (WindowManager.supportsWindowManagement && previousListId != null) {
      await WindowRegistryService.unregisterOpenList(previousListId.value);
      await WindowRegistryService.registerOpenList(listId.value);
    }

    final nextService = TodoListService(listId);
    _todoService = nextService;
    _listId = listId;
    _windowTitle = selected.title;
    await _catalog.markListActive(listId);
    await nextService.ready;
    previousService?.dispose();
    if (!mounted) return;
    setState(() {});
    if (widget.windowController != null) {
      await widget.windowController!.setTitle(_windowTitle);
    } else if (WindowManager.supportsWindowManagement) {
      await WindowManager.updateWindowTitle(_windowTitle);
    }
  }

  Future<void> _showLists() async {
    final lists = await _catalog.loadLists();
    final recoverableHistory = await _catalog.loadTaskHistory();
    if (!mounted) return;
    var shouldRecoverOldData = false;
    final selectedListId = await showAdaptiveDialog<TodoListId>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Todo lists'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
            child: SizedBox(
              width: 320,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return ListTile(
                    selected: list.id == _listId,
                    leading: const Icon(Icons.check_box_outlined),
                    title: Text(list.title),
                    onTap: () => Navigator.pop(dialogContext, list.id),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete list',
                      onPressed: () async {
                        if (lists.length == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('At least one list must remain.'),
                            ),
                          );
                          return;
                        }
                        final confirmed = await showAdaptiveDialog<bool>(
                          context: dialogContext,
                          builder:
                              (context) => AlertDialog.adaptive(
                                title: const Text('Delete list?'),
                                content: Text(
                                  'Delete "${list.title}" and all of its tasks?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed != true) return;
                        await _catalog.deleteList(list.id);
                        if (!dialogContext.mounted) return;
                        if (list.id == _listId) {
                          final fallback = lists.firstWhere(
                            (candidate) => candidate.id != list.id,
                          );
                          Navigator.pop(dialogContext, fallback.id);
                        } else {
                          Navigator.pop(dialogContext);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            if (recoverableHistory.isNotEmpty)
              TextButton(
                onPressed: () {
                  shouldRecoverOldData = true;
                  Navigator.pop(dialogContext);
                },
                child: const Text('Recover old data'),
              ),
            TextButton(
              onPressed: () async {
                final newList = await _catalog.createList();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, newList.id);
                }
              },
              child: const Text('New list'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
    if (selectedListId != null && mounted) {
      await _switchList(selectedListId);
    } else if (shouldRecoverOldData && mounted) {
      await _showTaskHistory();
    }
  }

  void _addTodo() {
    if (_controller.text.trim().isEmpty || _todoService == null) return;

    _runUndoable(() => _todoService!.addTodo(_controller.text.trim()));
    _controller.clear();
    _focusNode.requestFocus();
  }

  Future<void> _runUndoable(Future<void> Function() operation) async {
    final service = _todoService;
    if (service == null) return;
    final previousUndoRevision = service.undoRevision;
    await operation();
    if (mounted && service.undoRevision > previousUndoRevision) {
      _showUndoSnackBar();
    }
  }

  void _deleteTodo(String id) {
    final service = _todoService;
    if (service?.todoById(id) == null) return;
    service!.deleteTodoById(id).then((_) {
      if (mounted) _showUndoSnackBar();
    });
  }

  void _reorderSiblings(String? parentId, int oldIndex, int newIndex) {
    final service = _todoService;
    if (service != null) {
      _runUndoable(() => service.reorderSiblings(parentId, oldIndex, newIndex));
    }
  }

  void _toggleTodo(String id) {
    final service = _todoService;
    if (service?.todoById(id) == null) return;
    service!.toggleTodoById(id).then((_) {
      if (mounted) _showUndoSnackBar();
    });
  }

  void _addSubtask(String parentId, String text) {
    final service = _todoService;
    if (service != null) {
      _runUndoable(() => service.addSubtask(parentId, text));
    }
  }

  Future<bool> _nestTodo(String todoId, String parentId) async {
    final service = _todoService;
    if (service == null) return false;
    return service.nestTodo(todoId, parentId);
  }

  Future<void> _undoLastAction() async {
    final didUndo = await _todoService?.undoLastAction() ?? false;
    if (!didUndo || !mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('元に戻しました'),
        duration: const Duration(seconds: 3),
        action:
            _todoService!.canUndo
                ? SnackBarAction(
                  label: 'さらに元に戻す',
                  onPressed: () => _undoLastAction(),
                )
                : null,
      ),
    );
  }

  bool _canUseUndoShortcut() {
    if (_todoService?.canUndo != true) return false;

    final primaryFocus = FocusManager.instance.primaryFocus;
    final focusContext = primaryFocus?.context;
    final isEditingText =
        focusContext?.findAncestorWidgetOfExactType<EditableText>() != null;
    if (!isEditingText) return true;

    // The add field remains focused after submitting. Let Ctrl/⌘Z undo the
    // task once that field is empty, while preserving text editing undo when
    // the user is typing or editing a task title.
    return primaryFocus == _focusNode && _controller.text.isEmpty;
  }

  void _showUndoSnackBar() {
    if (!mounted || _todoService?.canUndo != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('操作しました'),
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () => _undoLastAction(),
          ),
        ),
      );
  }

  void _editTodo(String id, String text) {
    final service = _todoService;
    final todo = service?.todoById(id);
    if (todo == null || text.trim().isEmpty || todo.text == text.trim()) return;
    service!.updateTodoText(id, text).then((_) {
      if (mounted) _showUndoSnackBar();
    });
  }

  void _onTitleChanged(String newTitle) {
    setState(() {
      _windowTitle = newTitle;
    });
    if (_listId != null) {
      _catalog.updateTitle(_listId!, newTitle);
    }
    // Update the actual window title
    if (widget.windowController != null) {
      widget.windowController!.setTitle(newTitle);
    } else {
      WindowManager.updateWindowTitle(newTitle);
    }
  }

  void _showSettings() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  Future<void> _showTaskHistory() async {
    final restoredListId = await showAdaptiveDialog<TodoListId>(
      context: context,
      builder: (context) => TaskHistoryDialog(catalog: _catalog),
    );
    if (restoredListId != null && mounted) {
      await _switchList(restoredListId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            _UndoTodoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _UndoTodoIntent(),
      },
      child: Actions(
        actions: {
          _UndoTodoIntent: _UndoTodoAction(
            onInvoke: _undoLastAction,
            canUndo: _canUseUndoShortcut,
          ),
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          body: SafeArea(
            child: Column(
              children: [
                AppHeader(
                  controller: _controller,
                  focusNode: _focusNode,
                  onAddTodo: _addTodo,
                  onShowSettings: _showSettings,
                  onShowLists: _showLists,
                  windowTitle: _windowTitle,
                  onTitleChanged: _onTitleChanged,
                ),
                ListenableBuilder(
                  listenable: _todoService!,
                  builder: (context, child) {
                    return TodoList(
                      todos: _todoService!.todos,
                      onToggleTodo: _toggleTodo,
                      onDeleteTodo: _deleteTodo,
                      onReorderSiblings: _reorderSiblings,
                      onAddSubtask: _addSubtask,
                      onEditTodo: _editTodo,
                      onNestTodo: _nestTodo,
                      onUndoAction: _undoLastAction,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UndoTodoIntent extends Intent {
  const _UndoTodoIntent();
}

class _UndoTodoAction extends Action<_UndoTodoIntent> {
  final Future<void> Function() onInvoke;
  final bool Function() canUndo;

  _UndoTodoAction({required this.onInvoke, required this.canUndo});

  @override
  bool isEnabled(_UndoTodoIntent intent) {
    return canUndo();
  }

  @override
  Object? invoke(_UndoTodoIntent intent) {
    onInvoke();
    return null;
  }
}
