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
                icon: Icon(OctIcons.code_16),
              ),
              OctoUnderlineNavItem(
                label: 'Issues',
                icon: Icon(OctIcons.bug_16),
                trailing: OctoCounterLabel(12),
              ),
              OctoUnderlineNavItem(
                label: 'Pull requests',
                icon: Icon(OctIcons.git_pull_request_16),
                trailing: OctoCounterLabel(3),
              ),
              OctoUnderlineNavItem(
                label: 'Actions',
                icon: Icon(OctIcons.play_16),
              ),
              OctoUnderlineNavItem(
                label: 'Settings',
                icon: Icon(OctIcons.gear_16),
              ),
            ],
          ),
        ),
      ),
    ],
    // tabletLandscape (1024 × 768 logical) gives the 5-tab strip room to
    // breathe without horizontal overflow that phoneSmall would force.
    axes: MatrixAxes(themes: octoThemes, devices: [MatrixDevice.tabletLandscape]),
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
