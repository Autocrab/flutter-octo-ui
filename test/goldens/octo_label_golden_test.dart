import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  componentMatrixGolden(
    'octo_label',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'all_variants',
        builder: () => octoComponentWrap(
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OctoLabel('Bug'),
              OctoLabel('Feature', variant: OctoLabelVariant.accent),
              OctoLabel('Merged', variant: OctoLabelVariant.success),
              OctoLabel('Review', variant: OctoLabelVariant.attention),
              OctoLabel('Critical', variant: OctoLabelVariant.danger),
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
