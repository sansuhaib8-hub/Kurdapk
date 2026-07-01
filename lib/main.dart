import 'package:flutter/material.dart';
import 'theme.dart';
import 'shell_test_screen.dart';

void main() {
  runApp(const ForgeApp());
}

class ForgeApp extends StatelessWidget {
  const ForgeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const ShellTestScreen(),
    );
  }
}
