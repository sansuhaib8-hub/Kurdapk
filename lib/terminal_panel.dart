import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class TerminalEntry {
  final String command;
  final String output;
  final bool isError;
  TerminalEntry(this.command, this.output, {this.isError = false});
}

class LiveTerminalPanel extends StatefulWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const LiveTerminalPanel({super.key, required this.expanded, required this.onToggle});

  @override
  State<LiveTerminalPanel> createState() => _LiveTerminalPanelState();
}

class _LiveTerminalPanelState extends State<LiveTerminalPanel> {
  static const platform = MethodChannel('kurdapk/shell');
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TerminalEntry> _history = [];
  bool _running = false;

  Future<void> _runCommand(String cmd) async {
    if (cmd.trim().isEmpty) return;
    setState(() => _running = true);
    try {
      final result = await platform.invokeMethod('runCommand', {'cmd': cmd});
      setState(() {
        _history.add(TerminalEntry(cmd, result?.toString() ?? ''));
      });
    } on PlatformException catch (e) {
      setState(() {
        _history.add(TerminalEntry(cmd, e.message ?? 'unknown error', isError: true));
      });
    } finally {
      setState(() => _running = false);
      _controller.clear();
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      height: widget.expanded ? 260 : 34,
      decoration: BoxDecoration(
        color: AppColors.bg1.withOpacity(0.97),
        border: const Border(top: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(widget.expanded ? Icons.expand_more : Icons.expand_less, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  const Text('Terminal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const Spacer(),
                  if (_running)
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.blue)),
                ],
              ),
            ),
          ),
          if (widget.expanded) ...[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                itemCount: _history.length,
                itemBuilder: (context, i) {
                  final e = _history[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('❯ ${e.command}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w600)),
                        if (e.output.isNotEmpty)
                          Text(e.output,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: e.isError ? const Color(0xFFFF6B6B) : AppColors.textSecondary)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 6, 10, 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  const Text('❯', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textPrimary),
                      cursorColor: AppColors.green,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'کۆمەند بنووسە…',
                        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      ),
                      onSubmitted: _runCommand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
