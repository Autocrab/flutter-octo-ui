import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_action_list',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: OctoActionList(
            items: [
              OctoActionListItem(
                label: 'New issue',
                leading: Icon(Icons.add),
                onPressed: _noop,
              ),
              OctoActionListItem(
                label: 'New pull request',
                leading: Icon(Icons.merge_type),
                onPressed: _noop,
              ),
              OctoActionListItem(
                label: 'Settings',
                leading: Icon(Icons.settings_outlined),
                description: 'Repository preferences and integrations',
                onPressed: _noop,
              ),
              OctoActionListItem(
                label: 'Archive',
                leading: Icon(Icons.archive_outlined),
              ),
              OctoActionListItem(
                label: 'Delete repository',
                leading: Icon(Icons.delete_outline),
                variant: OctoActionListItemVariant.danger,
                onPressed: _noop,
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'selected',
        builder: () => const _Sampler(
          child: OctoActionList(
            items: [
              OctoActionListItem(label: 'Open', onPressed: _noop, selected: true),
              OctoActionListItem(label: 'Closed', onPressed: _noop),
              OctoActionListItem(label: 'All', onPressed: _noop),
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

void _noop() {}

class _Sampler extends StatelessWidget {
  final Widget child;

  const _Sampler({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(width: 280, child: child),
  );
}
