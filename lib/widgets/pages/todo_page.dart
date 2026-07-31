import 'package:flutter/material.dart';
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

class TodoPage extends StatefulWidget {
  final WindowController? windowController;
  final TodoListId? initialListId;

  const TodoPage({super.key, this.windowController, this.initialListId});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
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
    _initializeWindow();
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

    if (WindowManager.supportsWindowManagement) {
      if (widget.windowController == null) {
        await _catalog.markListActive(_listId!);
      }
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
    final selectedListId = await showDialog<TodoListId>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Todo lists'),
          content: SizedBox(
            width: 320,
            child: FutureBuilder<List<TodoListRecord>>(
              future: _catalog.loadLists(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final lists = snapshot.data!;
                return ListView.builder(
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
                          final confirmed = await showDialog<bool>(
                            context: dialogContext,
                            builder:
                                (context) => AlertDialog(
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
                );
              },
            ),
          ),
          actions: [
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
    }
  }

  void _addTodo() {
    if (_controller.text.trim().isEmpty || _todoService == null) return;

    _todoService!.addTodo(_controller.text.trim());
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _deleteTodo(String id) {
    _todoService?.deleteTodoById(id);
  }

  void _reorderSiblings(String? parentId, int oldIndex, int newIndex) {
    _todoService?.reorderSiblings(parentId, oldIndex, newIndex);
  }

  void _toggleTodo(String id) {
    _todoService?.toggleTodoById(id);
  }

  void _addSubtask(String parentId, String text) {
    _todoService?.addSubtask(parentId, text);
  }

  Future<bool> _nestTodo(String todoId, String parentId) async {
    final service = _todoService;
    if (service == null) return false;
    return service.nestTodo(todoId, parentId);
  }

  Future<void> _undoNesting() async {
    await _todoService?.undoLastNesting();
  }

  void _editTodo(String id, String text) {
    _todoService?.updateTodoText(id, text);
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
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
                  onUndoNesting: _undoNesting,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
