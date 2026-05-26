import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_underline_nav',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'repository-like',
        builder: () => const _Sampler(
          child: OctoUnderlineNav(
            selectedIndex: 0,
            onChanged: _noopInt,
            items: [
              OctoUnderlineNavItem(
                label: 'Code',
                icon: Icon(Icons.code),
              ),
              OctoUnderlineNavItem(
                label: 'Issues',
                icon: Icon(Icons.bug_report_outlined),
                trailing: OctoCounterLabel(12),
              ),
              OctoUnderlineNavItem(
                label: 'Pull requests',
                icon: Icon(Icons.merge_type),
                trailing: OctoCounterLabel(3),
              ),
              OctoUnderlineNavItem(
                label: 'Actions',
                icon: Icon(Icons.play_arrow_outlined),
              ),
              OctoUnderlineNavItem(
                label: 'Settings',
                icon: Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

void _noopInt(int _) {}

class _Sampler extends StatelessWidget {
  final Widget child;

  const _Sampler({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topLeft, child: child),
      );
}
