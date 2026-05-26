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
        items: const [
          OctoActionListItem(
            label: 'New issue',
            leading: Icon(OctIcons.plus_16),
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'New pull request',
            leading: Icon(OctIcons.git_pull_request_16),
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Open settings',
            leading: Icon(OctIcons.gear_16),
            description: 'Repository preferences and integrations',
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Toggle dark mode',
            leading: Icon(OctIcons.moon_16),
            onPressed: _noop,
          ),
        ],
        child: const SizedBox.expand(),
      ),
    );
  }
}

void _noop() {}
