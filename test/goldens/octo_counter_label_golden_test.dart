import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  componentMatrixGolden(
    'octo_counter_label',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'all_variants',
        builder: () => octoComponentWrap(
          const Wrap(
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
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
