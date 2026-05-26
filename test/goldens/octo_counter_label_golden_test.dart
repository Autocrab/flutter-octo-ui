import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_counter_label',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'all_variants',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OctoCounterLabel(3),
              OctoCounterLabel(12, variant: OctoCounterLabelVariant.primary),
              OctoCounterLabel(48, variant: OctoCounterLabelVariant.secondary),
              OctoCounterLabel(150, maxDisplayed: 99),
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

class _Sampler extends StatelessWidget {
  final Widget child;

  const _Sampler({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topLeft, child: child),
      );
}
