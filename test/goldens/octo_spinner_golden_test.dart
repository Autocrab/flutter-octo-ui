import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  componentMatrixGolden(
    'octo_spinner',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        // Park each spinner via motion-reduce so the snapshot stays
        // deterministic under freezeAnimations.
        builder: () => octoComponentWrap(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: SizedBox(
              width: 280,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OctoSpinner(size: OctoSpinnerSize.small),
                  OctoSpinner(),
                  OctoSpinner(size: OctoSpinnerSize.large),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
    freezeAnimations: true,
  );
}
