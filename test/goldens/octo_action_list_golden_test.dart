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
                leading: Icon(OctIcons.plus_16),
                onPressed: _noop,
              ),
              OctoActionListItem(
                label: 'New pull request',
                leading: Icon(OctIcons.git_pull_request_16),
                onPressed: _noop,
              ),
              OctoActionListItem(
                label: 'Settings',
                leading: Icon(OctIcons.gear_16),
                description: 'Repository preferences and integrations',
                onPressed: _noop,
              ),
              OctoActionListItem(
                label: 'Archive',
                leading: Icon(OctIcons.archive_16),
              ),
              OctoActionListItem(
                label: 'Delete repository',
                leading: Icon(OctIcons.trash_16),
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
