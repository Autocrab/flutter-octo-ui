import 'package:flutter/material.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

/// Both [OctoThemeData] palettes wrapped as [MatrixTheme.custom]. The
/// `themeData` is the Material adapter output (ADR-0004) so MaterialApp
/// chrome (`Scaffold`, dialogs, etc.) picks up Octo colours; `data` carries
/// the OctoThemeData itself so [wrapInOctoTheme] can install [OctoTheme]
/// above the auto-built `MaterialApp`.
final List<MatrixTheme> octoThemes = <MatrixTheme>[
  MatrixTheme.custom(
    'light',
    OctoThemeData.light().toMaterialTheme(),
    data: OctoThemeData.light(),
  ),
  MatrixTheme.custom(
    'dark',
    OctoThemeData.dark().toMaterialTheme(),
    data: OctoThemeData.dark(),
  ),
  // High-contrast variants — same palette family but with the
  // WCAG-AA-bumped fg / border tokens. Catches regressions where a
  // component reads from the wrong slot (e.g. uses fg.muted on
  // canvas.subtle instead of canvas.default).
  MatrixTheme.custom(
    'light-hc',
    OctoThemeData.light(variant: OctoColorSchemeVariant.highContrast).toMaterialTheme(),
    data: OctoThemeData.light(variant: OctoColorSchemeVariant.highContrast),
  ),
  MatrixTheme.custom(
    'dark-hc',
    OctoThemeData.dark(variant: OctoColorSchemeVariant.highContrast).toMaterialTheme(),
    data: OctoThemeData.dark(variant: OctoColorSchemeVariant.highContrast),
  ),
];

/// Wraps the auto-built [MaterialApp] in an [OctoTheme] pulled from
/// `combination.theme.data`. Pass as `wrapApp` to [matrixGolden].
Widget wrapInOctoTheme(Widget app, MatrixCombination combination) {
  final octo = combination.theme.data! as OctoThemeData;
  return OctoTheme(data: octo, child: app);
}

/// Wraps a [componentMatrixGolden] scenario in an [OctoTheme].
///
/// `componentMatrixGolden` builds the `MaterialApp` internally and doesn't
/// expose a `wrapApp` hook, so we read [OctoThemeData] out of the
/// inherited Material theme (it lives there as a `ThemeExtension`, see
/// [OctoThemeData.toMaterialTheme]) and install [OctoTheme] above the
/// scenario content.
Widget octoComponentWrap(Widget child) => Builder(
      builder: (context) {
        final octo = Theme.of(context).extension<OctoThemeData>()!;
        return OctoTheme(data: octo, child: child);
      },
    );

/// Wraps a focused-state scenario so the focus ring actually paints.
///
/// `OctoFocusRing` only shows when `FocusManager.instance.highlightMode` is
/// [FocusHighlightMode.traditional]. In production the manager auto-flips
/// to `traditional` after a keyboard event; in goldens nothing simulates a
/// keyboard press, so we force the strategy in [initState] and restore it
/// in [dispose] to keep tests isolated.
///
/// The wrapped subtree typically contains a widget with `autofocus: true`.
class GoldenFocusScope extends StatefulWidget {
  /// Wrapped scenario content.
  final Widget child;

  /// Wraps [child] in a focus-traditional override.
  const GoldenFocusScope({super.key, required this.child});

  @override
  State<GoldenFocusScope> createState() => _GoldenFocusScopeState();
}

class _GoldenFocusScopeState extends State<GoldenFocusScope> {
  late final FocusHighlightStrategy _previous;

  @override
  void initState() {
    super.initState();
    _previous = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  }

  @override
  void dispose() {
    FocusManager.instance.highlightStrategy = _previous;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Pixel-diff tolerance for every Octo golden, expressed as a fraction.
///
/// `0.01` = up to 1 % of pixels may differ before a test fails. This absorbs
/// sub-pixel anti-aliasing / font hinting differences between the local
/// macOS dev machine where baselines are baked and the CI macOS runner —
/// without hiding real visual regressions.
const double octoGoldenTolerance = 0.01;

/// Report formats for goldens.
///
/// Locally — silence (no HTML / Markdown / JSON / XML on disk). In CI
/// (detected by `isCiEnvironment`) — only the JUnit XML report, which the
/// CI workflow then publishes via `dorny/test-reporter` so failures surface
/// inline on the PR.
Set<MatrixReportFormat> get octoReportFormats => isCiEnvironment
    ? const <MatrixReportFormat>{MatrixReportFormat.junit}
    : const <MatrixReportFormat>{};
