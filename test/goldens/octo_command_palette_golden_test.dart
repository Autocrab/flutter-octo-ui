import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_command_palette',
    scenarios: <MatrixScenario>[
      MatrixScenario('open', builder: () => const _PaletteStage()),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

class _PaletteStage extends StatefulWidget {
  const _PaletteStage();

  @override
  State<_PaletteStage> createState() => _PaletteStageState();
}

class _PaletteStageState extends State<_PaletteStage> {
  final OctoCommandPaletteController _controller = OctoCommandPaletteController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.open());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return ColoredBox(
      color: theme.colors.canvas.defaultColor,
      child: OctoCommandPalette(
        controller: _controller,
        items: [
          OctoActionListItem(
            label: 'New issue',
            leading: const Icon(Icons.add),
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'New pull request',
            leading: const Icon(Icons.merge_type),
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Open settings',
            leading: const Icon(Icons.settings_outlined),
            description: 'Repository preferences and integrations',
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Toggle dark mode',
            leading: const Icon(Icons.dark_mode_outlined),
            onPressed: _noop,
          ),
        ],
        child: const SizedBox.expand(),
      ),
    );
  }
}

void _noop() {}
