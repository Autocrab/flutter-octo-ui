import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noopInt(int _) {}

void main() {
  componentMatrixGolden(
    'octo_pagination',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'compact',
        builder: () => octoComponentWrap(
          const OctoPagination(
            currentPage: 2,
            pageCount: 5,
            onPageChanged: _noopInt,
          ),
        ),
      ),
      MatrixScenario(
        'wide_middle',
        builder: () => octoComponentWrap(
          const OctoPagination(
            currentPage: 10,
            pageCount: 20,
            onPageChanged: _noopInt,
          ),
        ),
      ),
      MatrixScenario(
        'wide_start',
        builder: () => octoComponentWrap(
          const OctoPagination(
            currentPage: 1,
            pageCount: 20,
            onPageChanged: _noopInt,
          ),
        ),
      ),
      MatrixScenario(
        'wide_end',
        builder: () => octoComponentWrap(
          const OctoPagination(
            currentPage: 20,
            pageCount: 20,
            onPageChanged: _noopInt,
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
