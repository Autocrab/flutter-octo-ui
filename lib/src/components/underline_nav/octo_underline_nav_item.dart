import 'package:flutter/widgets.dart';

/// Data describing one tab in [OctoUnderlineNav].
///
/// Pure data — the corresponding `RenderObject` is built by
/// [OctoUnderlineNav] itself.
@immutable
class OctoUnderlineNavItem {
  /// Visible tab text.
  final String label;

  /// Optional leading widget (typically an icon).
  final Widget? icon;

  /// Optional trailing widget (typically an [OctoCounterLabel]).
  final Widget? trailing;

  /// Accessibility label. Defaults to [label] when omitted.
  final String? semanticLabel;

  /// Creates a tab item.
  const OctoUnderlineNavItem({
    required this.label,
    this.icon,
    this.trailing,
    this.semanticLabel,
  });
}
