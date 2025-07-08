import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'providers/theme_provider.dart';
import 'services/platform_channel_handler.dart';
import 'widgets/pages/todo_page.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (args.firstOrNull == 'multi_window') {
    // This is a sub window
    final windowId = int.parse(args[1]);
    final argument = args[2];
    runApp(TsubusuSubWindow(
      windowController: WindowController.fromWindowId(windowId),
      args: argument,
    ));
  } else {
    // This is the main window
    PlatformChannelHandler.initialize();
    runApp(const TsubusuApp());
  }
}

class TsubusuApp extends StatelessWidget {
  const TsubusuApp({super.key});

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

class TsubusuSubWindow extends StatelessWidget {
  final WindowController windowController;
  final String args;

  const TsubusuSubWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

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