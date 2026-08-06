import 'package:apputils/apputils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppUtilsExample());
}

class AppUtilsExample extends StatefulWidget {
  const AppUtilsExample({super.key});

  @override
  State<AppUtilsExample> createState() => _AppUtilsExampleState();
}

class _AppUtilsExampleState extends State<AppUtilsExample> {
  String _result = '尚未获取 ticket';
  bool _loading = false;

  Future<void> _getTicket() async {
    setState(() => _loading = true);
    try {
      final ticket = await AppUtils.instance.antiScraping.getTicket();
      if (!mounted) return;
      setState(() => _result = ticket.isEmpty ? 'SDK 返回了空 ticket' : ticket);
    } on AppUtilsException catch (error) {
      if (!mounted) return;
      setState(() => _result = '${error.code}: ${error.message}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AppUtils 示例')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(_result, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _getTicket,
                child: Text(_loading ? '获取中…' : '获取反扒 ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
