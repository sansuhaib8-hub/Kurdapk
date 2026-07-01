import 'package:flutter/material.dart';
import 'theme.dart';
import 'terminal_panel.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  bool explorerOpen = false;
  bool aiOpen = false;
  bool terminalExpanded = true;
  bool cmdkOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: Row(
                    children: [
                      _SidebarRail(
                        onExplorerTap: () => setState(() => explorerOpen = !explorerOpen),
                        onCmdTap: () => setState(() => cmdkOpen = true),
                      ),
                      const Expanded(child: _EditorArea()),
                    ],
                  ),
                ),
                LiveTerminalPanel(
                  expanded: terminalExpanded,
                  onToggle: () => setState(() => terminalExpanded = !terminalExpanded),
                ),
              ],
            ),
            if (explorerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => explorerOpen = false),
                  child: Container(color: Colors.black54),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              top: 0, bottom: 0,
              left: explorerOpen ? 0 : -260,
              width: 260,
              child: const _ExplorerDrawer(),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0, bottom: 0,
              right: aiOpen ? 0 : -340,
              width: 340,
              child: _AiPanel(onClose: () => setState(() => aiOpen = false)),
            ),
            Positioned(
              right: 14, bottom: 14,
              child: _AiFab(onTap: () => setState(() => aiOpen = !aiOpen)),
            ),
            if (cmdkOpen) _CommandPaletteOverlay(onClose: () => setState(() => cmdkOpen = false)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 10, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: const Text('2R', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('2R2H', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    border: Border.all(color: AppColors.green.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('⎇ feature/onDisconnect-fix',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: AppColors.green)),
                ),
              ],
            ),
          ),
          _iconBtn(Icons.undo),
          _iconBtn(Icons.redo),
          _iconBtn(Icons.save_outlined),
          Container(
            margin: const EdgeInsets.only(left: 6),
            width: 28, height: 28,
            decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.panelSoft,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class _SidebarRail extends StatelessWidget {
  final VoidCallback onExplorerTap;
  final VoidCallback onCmdTap;
  const _SidebarRail({required this.onExplorerTap, required this.onCmdTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      decoration: const BoxDecoration(
        color: AppColors.bg1,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _railIcon(Icons.folder_outlined, active: true, onTap: onExplorerTap, dot: true),
          _railIcon(Icons.search, onTap: onExplorerTap),
          _divider(),
          _railIcon(Icons.call_split, onTap: () {}),
          _railIcon(Icons.extension_outlined, onTap: () {}),
          _divider(),
          _railIcon(Icons.star_border, onTap: () {}),
          _railIcon(Icons.settings_outlined, onTap: () {}),
          _divider(),
          _railIcon(Icons.auto_awesome, onTap: onCmdTap),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 22, height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(vertical: 6));

  Widget _railIcon(IconData icon, {bool active = false, bool dot = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: active ? AppColors.blue.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 17, color: active ? AppColors.blue : AppColors.textTertiary),
              if (dot)
                Positioned(
                  bottom: 4, right: 5,
                  child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplorerDrawer extends StatelessWidget {
  const _ExplorerDrawer();
  static const _files = [
    _TreeItem('📂 lib', isFolder: true, indent: 0),
    _TreeItem('📂 screens', isFolder: true, indent: 1),
    _TreeItem('📄 login_screen.dart', indent: 2, active: true, gitTag: 'M'),
    _TreeItem('📄 online_game_screen.dart', indent: 2),
    _TreeItem('📂 services', isFolder: true, indent: 1),
    _TreeItem('📄 firebase_service.dart', indent: 2, gitTag: 'A'),
    _TreeItem('📄 main.dart', indent: 1),
    _TreeItem('📂 .github/workflows', isFolder: true, indent: 0),
    _TreeItem('📄 build.yml', indent: 1),
    _TreeItem('📄 pubspec.yaml', indent: 0, fav: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1.withOpacity(0.97),
        border: const Border(right: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EXPLORER · 2R2H', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.panelSoft, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)),
                  child: const Row(children: [
                    Icon(Icons.search, size: 14, color: AppColors.textTertiary),
                    SizedBox(width: 6),
                    Text('Search files…', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  ]),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: _files.map((f) => f.build()).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeItem {
  final String label;
  final bool isFolder;
  final int indent;
  final bool active;
  final bool fav;
  final String? gitTag;
  const _TreeItem(this.label, {this.isFolder = false, this.indent = 0, this.active = false, this.fav = false, this.gitTag});

  Widget build() {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: EdgeInsets.fromLTRB(8.0 + indent * 14, 6, 8, 6),
      decoration: BoxDecoration(
        color: active ? AppColors.blue.withOpacity(0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: active ? AppColors.blue : (isFolder ? AppColors.textPrimary : AppColors.textSecondary), fontWeight: isFolder ? FontWeight.w500 : FontWeight.normal)),
          ),
          if (fav) const Icon(Icons.star, size: 11, color: AppColors.amber),
          if (gitTag != null)
            Text(gitTag!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: gitTag == 'M' ? AppColors.amber : AppColors.green)),
        ],
      ),
    );
  }
}

class _EditorArea extends StatelessWidget {
  const _EditorArea();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 36,
          decoration: const BoxDecoration(color: AppColors.bg1, border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              _tab('login_screen.dart', active: true, modified: true),
              _tab('firebase_service.dart'),
              _tab('main.dart'),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.bg0,
            padding: const EdgeInsets.all(12),
            child: const SingleChildScrollView(
              child: Text(
                'class LoginScreen extends StatefulWidget {\n'
                '  const LoginScreen({super.key});\n\n'
                '  @override\n'
                '  State<LoginScreen> createState() => _LoginScreenState();\n'
                '}\n\n'
                '// TODO: دواتر CodeMirror editor ڕاستی لێرە دادەمەزرێنین',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.6, color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tab(String name, {bool active = false, bool modified = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.bg0 : Colors.transparent,
        border: Border(
          right: const BorderSide(color: AppColors.border),
          bottom: BorderSide(color: active ? AppColors.blue : Colors.transparent, width: 2),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: const Color(0xFF54C5F8), borderRadius: BorderRadius.circular(2))),
        Text(name, style: TextStyle(fontSize: 11.5, color: active ? AppColors.textPrimary : AppColors.textTertiary)),
        if (modified) Container(width: 6, height: 6, margin: const EdgeInsets.only(left: 6), decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle)),
      ]),
    );
  }
}


class _AiPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _AiPanel({required this.onClose});
  static const _steps = [
    ('Reading project structure', true),
    ('Editing login_screen.dart', true),
    ('Running flutter analyze…', false),
    ('Create commit', false),
    ('Push to GitHub', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bg1.withOpacity(0.97), border: const Border(left: BorderSide(color: AppColors.borderStrong))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
            child: Row(
              children: [
                Container(width: 30, height: 30, decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center, child: const Text('✦', style: TextStyle(color: Colors.white))),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('AI Engineer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    Text('working on login_screen.dart', style: TextStyle(fontSize: 10, color: AppColors.green)),
                  ]),
                ),
                InkWell(onTap: onClose, child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fixing build error · Task #114', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ..._steps.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          Icon(s.$2 ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: s.$2 ? AppColors.green : AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.$1, style: TextStyle(fontSize: 11.5, color: s.$2 ? AppColors.textPrimary : AppColors.textTertiary))),
                        ]),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.panelSoft, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                  child: const Text('Ask AI or type a command…', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 36, height: 36, decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send, size: 16, color: Colors.white)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AiFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AiFab({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(18), boxShadow: [
          BoxShadow(color: AppColors.violet.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ]),
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
      ),
    );
  }
}

}

class _CommandPaletteOverlay extends StatelessWidget {
  final VoidCallback onClose;
  const _CommandPaletteOverlay({required this.onClose});
  static const _items = [
    ('⚠', 'Fix Build Error', true),
    ('＋', 'Generate Settings Page', false),
    ('🧬', 'Refactor login_screen.dart', false),
    ('📦', 'Build APK (release)', false),
    ('⎇', 'Commit & Push', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.only(top: 90, left: 28, right: 28),
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(color: AppColors.bg1.withOpacity(0.95), border: Border.all(color: AppColors.borderStrong), borderRadius: BorderRadius.circular(18)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: const Row(children: [
                      Icon(Icons.auto_awesome, size: 16, color: AppColors.blue),
                      SizedBox(width: 9),
                      Expanded(child: Text('Fix build error, generate a screen…', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: _items.map((it) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(color: it.$3 ? AppColors.blue.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                        child: Row(children: [
                          Text(it.$1, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(it.$2, style: TextStyle(fontSize: 12, color: it.$3 ? AppColors.textPrimary : AppColors.textSecondary))),
                        ]),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
