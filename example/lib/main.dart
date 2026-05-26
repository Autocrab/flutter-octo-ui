import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:octo_ui/octo_ui.dart';

void main() => runApp(const KitchenSinkApp());

class KitchenSinkApp extends StatefulWidget {
  const KitchenSinkApp({super.key});

  @override
  State<KitchenSinkApp> createState() => _KitchenSinkAppState();
}

class _KitchenSinkAppState extends State<KitchenSinkApp> {
  bool _dark = false;
  bool _highContrast = false;
  final OctoCommandPaletteController _paletteController =
      OctoCommandPaletteController();

  void _toggleDark() => setState(() => _dark = !_dark);

  void _toggleHighContrast() => setState(() => _highContrast = !_highContrast);

  @override
  void dispose() {
    _paletteController.dispose();
    super.dispose();
  }

  List<OctoActionListItem> _paletteItems() => [
        OctoActionListItem(
          label: _dark ? 'Switch to light theme' : 'Switch to dark theme',
          leading: Icon(
              _dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: _toggleDark,
        ),
        OctoActionListItem(
          label: _highContrast
              ? 'Switch to standard contrast'
              : 'Switch to high contrast',
          leading:
              Icon(_highContrast ? Icons.contrast : Icons.contrast_outlined),
          onPressed: _toggleHighContrast,
        ),
        OctoActionListItem(
          label: 'New issue',
          description: 'Open the issue composer',
          leading: const Icon(Icons.add),
          onPressed: () {},
        ),
        OctoActionListItem(
          label: 'Open pull requests',
          leading: const Icon(Icons.merge_type),
          onPressed: () {},
        ),
        OctoActionListItem(
          label: 'Repository settings',
          leading: const Icon(Icons.settings_outlined),
          onPressed: () {},
        ),
        OctoActionListItem(
          label: 'Delete repository',
          leading: const Icon(Icons.delete_outline),
          variant: OctoActionListItemVariant.danger,
          onPressed: () {},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final variant = _highContrast
        ? OctoColorSchemeVariant.highContrast
        : OctoColorSchemeVariant.standard;
    final octo = _dark
        ? OctoThemeData.dark(variant: variant)
        : OctoThemeData.light(variant: variant);
    return OctoTheme(
      data: octo,
      child: MaterialApp(
        title: 'octo_ui kitchen sink',
        debugShowCheckedModeBanner: false,
        theme: octo.toMaterialTheme(),
        home: OctoCommandPalette(
          controller: _paletteController,
          items: _paletteItems(),
          // Cmd+K on macOS, Ctrl+K elsewhere — same activator covers both
          // because LogicalKeyboardKey.meta maps to the platform's command
          // key on macOS and the Windows / Super key on Linux. For desktops
          // a separate `control: true` activator could be added.
          openShortcut: const SingleActivator(
            LogicalKeyboardKey.keyK,
            meta: true,
          ),
          child: KitchenSinkPage(
            isDark: _dark,
            isHighContrast: _highContrast,
            onToggleTheme: _toggleDark,
            onToggleHighContrast: _toggleHighContrast,
            onOpenPalette: _paletteController.open,
          ),
        ),
      ),
    );
  }
}

class KitchenSinkPage extends StatefulWidget {
  final bool isDark;
  final bool isHighContrast;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleHighContrast;
  final VoidCallback onOpenPalette;

  const KitchenSinkPage({
    super.key,
    required this.isDark,
    required this.isHighContrast,
    required this.onToggleTheme,
    required this.onToggleHighContrast,
    required this.onOpenPalette,
  });

  @override
  State<KitchenSinkPage> createState() => _KitchenSinkPageState();
}

class _KitchenSinkPageState extends State<KitchenSinkPage> {
  final TextEditingController _emailController = TextEditingController();
  final OctoMenuController _menuController = OctoMenuController();
  bool _showError = false;
  String _lastAction = '';

  @override
  void dispose() {
    _emailController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _record(String action) => setState(() => _lastAction = action);

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colors.canvas.defaultColor,
      appBar: AppBar(
        backgroundColor: theme.colors.canvas.subtle,
        surfaceTintColor: theme.colors.canvas.subtle,
        elevation: 0,
        shape:
            Border(bottom: BorderSide(color: theme.colors.border.defaultColor)),
        title: const OctoText('octo_ui kitchen sink', kind: OctoTextKind.title),
        actions: [
          OctoTooltip(
            message: 'Open command palette (⌘K)',
            child: OctoIconButton(
              icon: Icons.search,
              onPressed: widget.onOpenPalette,
              variant: OctoButtonVariant.invisible,
              semanticLabel: 'Open command palette',
            ),
          ),
          SizedBox(width: theme.spacing.gap.sm),
          OctoIconButton(
            icon: widget.isHighContrast
                ? Icons.contrast
                : Icons.contrast_outlined,
            onPressed: widget.onToggleHighContrast,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isHighContrast
                ? 'Switch to standard contrast'
                : 'Switch to high contrast',
          ),
          SizedBox(width: theme.spacing.gap.sm),
          OctoIconButton(
            icon: widget.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            onPressed: widget.onToggleTheme,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isDark
                ? 'Switch to light theme'
                : 'Switch to dark theme',
          ),
          SizedBox(width: theme.spacing.gap.md),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  title: 'Labels',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      OctoLabel('Bug'),
                      OctoLabel('Feature', variant: OctoLabelVariant.accent),
                      OctoLabel('Merged', variant: OctoLabelVariant.success),
                      OctoLabel('Review', variant: OctoLabelVariant.attention),
                      OctoLabel('Critical', variant: OctoLabelVariant.danger),
                    ],
                  ),
                ),
                _Section(
                  title: 'Counter labels',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: const [
                      OctoText('Issues', kind: OctoTextKind.body),
                      OctoCounterLabel(12),
                      OctoText('Pull requests', kind: OctoTextKind.body),
                      OctoCounterLabel(
                        4,
                        variant: OctoCounterLabelVariant.primary,
                      ),
                      OctoText('Stars', kind: OctoTextKind.body),
                      OctoCounterLabel(
                        1248,
                        maxDisplayed: 999,
                        variant: OctoCounterLabelVariant.secondary,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Buttons — variants',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoButton.label('Save',
                          onPressed: () {}, variant: OctoButtonVariant.primary),
                      OctoButton.label('Cancel', onPressed: () {}),
                      OctoButton.label('Delete',
                          onPressed: () {}, variant: OctoButtonVariant.danger),
                      OctoButton.label('Edit',
                          onPressed: () {},
                          variant: OctoButtonVariant.invisible),
                      OctoButton.label('Disabled', onPressed: null),
                    ],
                  ),
                ),
                _Section(
                  title: 'Buttons — sizes',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoButton.label('Small',
                          onPressed: () {}, size: OctoButtonSize.small),
                      OctoButton.label('Medium', onPressed: () {}),
                      OctoButton.label('Large',
                          onPressed: () {}, size: OctoButtonSize.large),
                    ],
                  ),
                ),
                _Section(
                  title: 'Icon buttons',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoIconButton(
                        icon: Icons.star_outline,
                        onPressed: () {},
                        semanticLabel: 'Star',
                      ),
                      OctoIconButton(
                        icon: Icons.favorite_outline,
                        onPressed: () {},
                        variant: OctoButtonVariant.primary,
                        semanticLabel: 'Favorite',
                      ),
                      OctoIconButton(
                        icon: Icons.more_horiz,
                        onPressed: () {},
                        variant: OctoButtonVariant.invisible,
                        semanticLabel: 'More',
                      ),
                      const OctoIconButton(
                        icon: Icons.lock_outline,
                        onPressed: null,
                        semanticLabel: 'Locked',
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Flashes',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      OctoFlash(
                          message: 'A new release is available.',
                          icon: Icons.info_outline),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Changes saved successfully.',
                        variant: OctoFlashVariant.success,
                        icon: Icons.check_circle_outline,
                      ),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Review required before merge.',
                        variant: OctoFlashVariant.attention,
                        icon: Icons.error_outline,
                      ),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Build failed — see the logs for details.',
                        variant: OctoFlashVariant.danger,
                        icon: Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Text field',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OctoTextField(
                        label: 'Email',
                        placeholder: 'you@example.com',
                        controller: _emailController,
                        helperText: 'Used for login only',
                        errorText: _showError ? 'Invalid email address' : null,
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      OctoButton.label(
                        _showError ? 'Hide error' : 'Show error',
                        onPressed: () =>
                            setState(() => _showError = !_showError),
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      const OctoTextField(
                        placeholder: 'disabled',
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Tooltips — hover or long-press',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoTooltip(
                        message: 'Save changes (⌘S)',
                        child: OctoButton.label(
                          'Save',
                          onPressed: () => _record('Save tapped'),
                          variant: OctoButtonVariant.primary,
                        ),
                      ),
                      OctoTooltip(
                        message: 'Watch this repository',
                        child: OctoIconButton(
                          icon: Icons.visibility_outlined,
                          onPressed: () => _record('Watch tapped'),
                          semanticLabel: 'Watch',
                        ),
                      ),
                      OctoTooltip(
                        message: 'Pinned for later',
                        child: OctoIconButton(
                          icon: Icons.push_pin_outlined,
                          onPressed: () => _record('Pin tapped'),
                          variant: OctoButtonVariant.invisible,
                          semanticLabel: 'Pin',
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Menu — controller-driven popover',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OctoMenu(
                        controller: _menuController,
                        items: [
                          OctoActionListItem(
                            label: 'New issue',
                            leading: const Icon(Icons.add),
                            onPressed: () => _record('New issue'),
                          ),
                          OctoActionListItem(
                            label: 'New pull request',
                            leading: const Icon(Icons.merge_type),
                            onPressed: () => _record('New PR'),
                          ),
                          OctoActionListItem(
                            label: 'Settings',
                            leading: const Icon(Icons.settings_outlined),
                            onPressed: () => _record('Settings'),
                          ),
                          OctoActionListItem(
                            label: 'Delete repository',
                            leading: const Icon(Icons.delete_outline),
                            variant: OctoActionListItemVariant.danger,
                            onPressed: () => _record('Delete'),
                          ),
                        ],
                        child: OctoButton.label(
                          'More actions',
                          onPressed: _menuController.toggle,
                          trailingIcon: const Icon(Icons.expand_more),
                        ),
                      ),
                      SizedBox(width: theme.spacing.gap.md),
                      Flexible(
                        child: OctoText(
                          _lastAction.isEmpty
                              ? 'Pick something from the menu…'
                              : 'Last action: $_lastAction',
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Action list — inline (e.g. drawer / sidebar)',
                  child: SizedBox(
                    width: 320,
                    child: OctoActionList(
                      items: [
                        OctoActionListItem(
                          label: 'Code',
                          leading: const Icon(Icons.code),
                          trailing: const OctoCounterLabel(42),
                          onPressed: () => _record('Code'),
                          selected: true,
                        ),
                        OctoActionListItem(
                          label: 'Issues',
                          leading: const Icon(Icons.bug_report_outlined),
                          trailing: const OctoCounterLabel(7),
                          onPressed: () => _record('Issues'),
                        ),
                        OctoActionListItem(
                          label: 'Pull requests',
                          leading: const Icon(Icons.merge_type),
                          trailing: const OctoCounterLabel(3),
                          onPressed: () => _record('PRs'),
                        ),
                        OctoActionListItem(
                          label: 'Settings',
                          leading: const Icon(Icons.settings_outlined),
                          description: 'Members, integrations, secrets',
                          onPressed: () => _record('Settings'),
                        ),
                      ],
                    ),
                  ),
                ),
                _Section(
                  title: 'Command palette — ⌘K from anywhere',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OctoButton.label(
                        'Open command palette',
                        leadingIcon: const Icon(Icons.search),
                        onPressed: widget.onOpenPalette,
                        variant: OctoButtonVariant.primary,
                      ),
                      SizedBox(width: theme.spacing.gap.md),
                      Flexible(
                        child: OctoText(
                          'Or press ⌘K from anywhere on the page.',
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OctoText(title, kind: OctoTextKind.heading),
          SizedBox(height: theme.spacing.gap.md),
          Container(
            padding: EdgeInsets.all(theme.spacing.gap.lg),
            decoration: BoxDecoration(
              color: theme.colors.canvas.subtle,
              border: Border.all(color: theme.colors.border.defaultColor),
              borderRadius:
                  BorderRadius.all(Radius.circular(theme.radii.medium)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
