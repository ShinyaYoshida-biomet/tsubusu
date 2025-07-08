import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'providers/theme_provider.dart';
import 'services/window_manager.dart';
import 'widgets/pages/todo_page.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    runApp(TsubusuWindow(windowController: WindowController.fromWindowId(windowId)));
  } else {
    runApp(const TsubusuWindow());
  }
}

class TsubusuWindow extends StatelessWidget {
  final WindowController? windowController;

  const TsubusuWindow({super.key, this.windowController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tsubusu',
            theme: themeProvider.themeData,
            home: const TodoPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}