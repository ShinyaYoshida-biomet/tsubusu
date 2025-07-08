import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/pages/todo_page.dart';

void main() {
  runApp(const TsubusuApp());
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