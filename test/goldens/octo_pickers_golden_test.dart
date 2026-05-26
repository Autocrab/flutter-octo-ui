import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noopVoid() {}
void _noopStr(String _) {}

void main() {
  matrixGolden(
    'octo_pickers',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'segmented_control',
        builder: () => _Sampler(
          child: OctoSegmentedControl<String>(
            value: 'open',
            onChanged: _noopStr,
            items: const [
              OctoSegmentedControlItem(value: 'all', label: 'All'),
              OctoSegmentedControlItem(value: 'open', label: 'Open'),
              OctoSegmentedControlItem(
                value: 'closed',
                label: 'Closed',
                icon: Icon(OctIcons.check_circle_16),
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'chips',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OctoChip(label: 'frontend'),
              OctoChip(label: 'urgent', variant: OctoChipVariant.danger, onDismiss: _noopVoid),
              OctoChip(label: 'review', variant: OctoChipVariant.attention, onDismiss: _noopVoid),
              OctoChip(label: 'merged', variant: OctoChipVariant.success, onPressed: _noopVoid),
              OctoChip(label: 'active', variant: OctoChipVariant.accent, onPressed: _noopVoid),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'dropdown_closed',
        builder: () => const _Sampler(
          child: OctoDropdown<String>(
            value: 'medium',
            onChanged: _noopStr,
            items: [
              OctoDropdownItem(value: 'low', label: 'Low'),
              OctoDropdownItem(value: 'medium', label: 'Medium'),
              OctoDropdownItem(value: 'high', label: 'High'),
            ],
          ),
        ),
      ),
      MatrixScenario('dropdown_open', builder: () => const _DropdownOpenStage()),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

class _DropdownOpenStage extends StatefulWidget {
  const _DropdownOpenStage();

  @override
  State<_DropdownOpenStage> createState() => _DropdownOpenStageState();
}

class _DropdownOpenStageState extends State<_DropdownOpenStage> {
  final OctoMenuController _menu = OctoMenuController();
  String? _value = 'medium';

  @override
  void initState() {
    super.initState();
    // Open the menu after the first frame so the snapshot captures the
    // popover, not just the trigger button.
    WidgetsBinding.instance.addPostFrameCallback((_) => _menu.open());
  }

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Sampler(
      child: OctoDropdown<String>(
        controller: _menu,
        value: _value,
        onChanged: (v) => setState(() => _value = v),
        items: const [
          OctoDropdownItem(value: 'low', label: 'Low'),
          OctoDropdownItem(value: 'medium', label: 'Medium'),
          OctoDropdownItem(value: 'high', label: 'High'),
        ],
      ),
    );
  }
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
