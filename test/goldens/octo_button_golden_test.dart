import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  componentMatrixGolden(
    'octo_button',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'variants',
        builder: () => octoComponentWrap(
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoButton.label('Save', onPressed: _noop, variant: OctoButtonVariant.primary),
              OctoButton.label('Cancel', onPressed: _noop),
              OctoButton.label('Delete', onPressed: _noop, variant: OctoButtonVariant.danger),
              OctoButton.label('Edit', onPressed: _noop, variant: OctoButtonVariant.invisible),
              OctoButton.label('Submit', onPressed: null),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'sizes',
        builder: () => octoComponentWrap(
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoButton.label('Small', onPressed: _noop, size: OctoButtonSize.small),
              OctoButton.label('Medium', onPressed: _noop),
              OctoButton.label('Large', onPressed: _noop, size: OctoButtonSize.large),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'hovered',
        builder: () => octoComponentWrap(
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoButton.label(
                'Primary',
                onPressed: _noop,
                variant: OctoButtonVariant.primary,
                debugStates: const {WidgetState.hovered},
              ),
              OctoButton.label(
                'Standard',
                onPressed: _noop,
                debugStates: const {WidgetState.hovered},
              ),
              OctoButton.label(
                'Invisible',
                onPressed: _noop,
                variant: OctoButtonVariant.invisible,
                debugStates: const {WidgetState.hovered},
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'pressed',
        builder: () => octoComponentWrap(
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoButton.label(
                'Primary',
                onPressed: _noop,
                variant: OctoButtonVariant.primary,
                debugStates: const {WidgetState.pressed},
              ),
              OctoButton.label(
                'Standard',
                onPressed: _noop,
                debugStates: const {WidgetState.pressed},
              ),
              OctoButton.label(
                'Danger',
                onPressed: _noop,
                variant: OctoButtonVariant.danger,
                debugStates: const {WidgetState.pressed},
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'focused',
        builder: () => GoldenFocusScope(
          child: octoComponentWrap(
            OctoButton.label('Focused', onPressed: _noop, autofocus: true),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

void _noop() {}
