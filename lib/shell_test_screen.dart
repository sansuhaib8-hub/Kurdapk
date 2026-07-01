import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShellTestScreen extends StatefulWidget {
  const ShellTestScreen({super.key});
  @override
  State<ShellTestScreen> createState() => _ShellTestScreenState();
}

class _ShellTestScreenState extends State<ShellTestScreen> {
  static const platform = MethodChannel('kurdapk/shell');
  String output = 'کرتە بکە بۆ تاقیکردنەوە';

  Future<void> runTest() async {
    try {
      final result = await platform.invokeMethod('runCommand', {'cmd': 'echo hello from android && uname -a'});
      setState(() => output = result.toString());
    } on PlatformException catch (e) {
      setState(() => output = 'هەڵە: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: runTest, child: const Text('Run Shell Command')),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(output, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }
}
