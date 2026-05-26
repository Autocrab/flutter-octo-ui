import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

class _PR {
  final int number;
  final String title;
  final String author;
  final int comments;
  final OctoStateLabelVariant status;
  const _PR(this.number, this.title, this.author, this.comments, this.status);
}

const _rows = [
  _PR(42, 'Add tabs component', 'anna', 5, OctoStateLabelVariant.open),
  _PR(43, 'Fix timeline rail', 'bob', 2, OctoStateLabelVariant.merged),
  _PR(44, 'Cut 0.6 release', 'cara', 0, OctoStateLabelVariant.draft),
  _PR(45, 'Switch chip dismiss', 'dee', 8, OctoStateLabelVariant.closed),
];

List<OctoDataColumn<_PR>> _buildColumns() => [
      OctoDataColumn<_PR>(label: '#', text: (r) => '#${r.number}'),
      // Title is the wide flex column — it soaks up the leftover space
      // while every other column hugs its content via IntrinsicColumnWidth.
      OctoDataColumn<_PR>(
        label: 'Title',
        text: (r) => r.title,
        sortable: true,
        flex: 1,
      ),
      OctoDataColumn<_PR>(
        label: 'Status',
        cell: (_, r) => OctoStateLabel(
          label: r.status.name,
          variant: r.status,
          emphasis: OctoStateLabelEmphasis.low,
        ),
      ),
      OctoDataColumn<_PR>(label: 'Author', text: (r) => r.author),
      OctoDataColumn<_PR>(
        label: 'Comments',
        text: (r) => '${r.comments}',
        alignment: OctoDataColumnAlignment.end,
        sortable: true,
      ),
    ];

void main() {
  matrixGolden(
    'octo_data_table',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_PR>(columns: _buildColumns(), rows: _rows),
          ),
        ),
      ),
      MatrixScenario(
        'sorted_desc',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_PR>(
              columns: _buildColumns(),
              rows: _rows,
              sortColumnIndex: 4,
              sortDirection: OctoSortDirection.desc,
            ),
          ),
        ),
      ),
      MatrixScenario(
        'compact',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_PR>(
              columns: _buildColumns(),
              rows: _rows,
              density: OctoDataTableDensity.compact,
              zebra: false,
            ),
          ),
        ),
      ),
      MatrixScenario(
        'empty',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_PR>(
              columns: _buildColumns(),
              rows: const [],
              emptyMessage: 'No PRs match the filter',
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(
      themes: octoThemes,
      // DataTable is wide — phoneSmall (320 px) crams cells to a single
      // character per column. Use a tablet-landscape viewport so the
      // golden reflects how the component is actually consumed (admin
      // panels, devtools).
      devices: [MatrixDevice.tabletLandscape],
    ),
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
