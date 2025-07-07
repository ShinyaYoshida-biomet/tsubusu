import 'package:flutter/material.dart';
import 'widgets/pages/todo_page.dart';

void main() {
  runApp(const TsubusuApp());
}

class TsubusuApp extends StatelessWidget {
  const TsubusuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tsubusu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}