import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  componentMatrixGolden(
    'octo_collapsible',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => octoComponentWrap(
          const SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoCollapsible(
                  title: 'Collapsed section',
                  child: Text(
                    'Hidden body — only the chevron and title show.',
                  ),
                ),
                SizedBox(height: 12),
                OctoCollapsible(
                  title: 'Expanded section',
                  initiallyExpanded: true,
                  child: Text(
                    'Body content is visible while the chevron points down.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
