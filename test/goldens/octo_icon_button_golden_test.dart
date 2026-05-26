import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

const _star = IconData(0xe838, fontFamily: 'MaterialIcons');

void main() {
  componentMatrixGolden(
    'octo_icon_button',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'variants',
        builder: () => octoComponentWrap(
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoIconButton(icon: _star, onPressed: _noop, semanticLabel: 'Star'),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                variant: OctoButtonVariant.primary,
                semanticLabel: 'Star',
              ),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                variant: OctoButtonVariant.invisible,
                semanticLabel: 'Star',
              ),
              OctoIconButton(icon: _star, onPressed: null, semanticLabel: 'Star'),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'sizes',
        builder: () => octoComponentWrap(
          const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                size: OctoButtonSize.small,
                semanticLabel: 'Star',
              ),
              OctoIconButton(icon: _star, onPressed: _noop, semanticLabel: 'Star'),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                size: OctoButtonSize.large,
                semanticLabel: 'Star',
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'hovered',
        builder: () => octoComponentWrap(
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                semanticLabel: 'Star',
                debugStates: {WidgetState.hovered},
              ),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                variant: OctoButtonVariant.invisible,
                semanticLabel: 'Star',
                debugStates: {WidgetState.hovered},
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'pressed',
        builder: () => octoComponentWrap(
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                semanticLabel: 'Star',
                debugStates: {WidgetState.pressed},
              ),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                variant: OctoButtonVariant.primary,
                semanticLabel: 'Star',
                debugStates: {WidgetState.pressed},
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'focused',
        builder: () => GoldenFocusScope(
          child: octoComponentWrap(
            const OctoIconButton(
              icon: _star,
              onPressed: _noop,
              semanticLabel: 'Star',
              autofocus: true,
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

void _noop() {}
