import 'package:flutter/material.dart';
import 'theme.dart';
import 'alpine_service.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TerminalEntry> _history = [];
  bool _running = false;
  bool _installed = false;
  bool _installing = false;
  String _installStatus = '';

  @override
  void initState() {
    super.initState();
    _checkInstalled();
  }

  Future<void> _checkInstalled() async {
    final installed = await AlpineService.isInstalled();
    setState(() => _installed = installed);
  }

  Future<void> _installAlpine() async {
    setState(() {
      _installing = true;
      _installStatus = 'دەستپێکردن...';
    });
    final result = await AlpineService.install(
      onProgress: (status) {
        if (mounted) setState(() => _installStatus = status);
      },
    );
    setState(() {
      _installing = false;
      _installed = result == 'سەرکەوتوو';
      _installStatus = result == 'سەرکەوتوو' ? '' : result;
    });
  }

  Future<void> _runCommand(String cmd) async {
    if (cmd.trim().isEmpty) return;
    setState(() => _running = true);
    try {
      final output = await AlpineService.runCommand(cmd);
      setState(() {
        _history.add(TerminalEntry(cmd, output, isError: output.startsWith('هەڵە:')));
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
                  if (_installed) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), border: Border.all(color: AppColors.green.withOpacity(0.3)), borderRadius: BorderRadius.circular(6)),
                      child: const Text('alpine', style: TextStyle(fontSize: 9, color: AppColors.green)),
                    ),
                  ],
                  const Spacer(),
                  if (_running)
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.blue)),
                ],
              ),
            ),
          ),
          if (widget.expanded) ...[
            if (!_installed)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_installing) ...[
                          const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue)),
                          const SizedBox(height: 10),
                          Text(_installStatus, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
                        ] else ...[
                          const Text('ژینگەی Linux (Alpine) دامەزراو نییە', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          const Text('پێویستە بۆ ڕاکردنی python/git/کۆمەندی ڕاستی', style: TextStyle(fontSize: 10, color: AppColors.textTertiary), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _installAlpine,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white),
                            child: const Text('دامەزراندن (~٦٨ مەگابایت)'),
                          ),
                          if (_installStatus.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(_installStatus, style: const TextStyle(fontSize: 10, color: Color(0xFFFF6B6B)), textAlign: TextAlign.center),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else ...[
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
                            SelectableText(e.output,
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
        ],
      ),
    );
  }
}
