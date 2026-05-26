import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

const _info = IconData(0xe88e, fontFamily: 'MaterialIcons');

void main() {
  componentMatrixGolden(
    'octo_flash',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'info',
        builder: () => octoComponentWrap(
          const OctoFlash(message: 'New release available'),
        ),
      ),
      MatrixScenario(
        'success',
        builder: () => octoComponentWrap(
          const OctoFlash(
            message: 'Saved successfully',
            variant: OctoFlashVariant.success,
            icon: _info,
          ),
        ),
      ),
      MatrixScenario(
        'attention',
        builder: () => octoComponentWrap(
          const OctoFlash(
            message: 'Review required before merge',
            variant: OctoFlashVariant.attention,
          ),
        ),
      ),
      MatrixScenario(
        'danger',
        builder: () => octoComponentWrap(
          const OctoFlash(
            message: 'Build failed — see logs',
            variant: OctoFlashVariant.danger,
            icon: _info,
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
