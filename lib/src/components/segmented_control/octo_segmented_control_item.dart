import 'package:flutter/widgets.dart';

/// One segment in an [OctoSegmentedControl].
///
/// Pass either a [label], an [icon], or both. At least one must be set —
/// an empty segment is rejected by `assert`.
@immutable
class OctoSegmentedControlItem<T> {
  /// Identity of this segment inside the group.
  final T value;

  /// Visible text. Optional when [icon] is set.
  final String? label;

  /// Optional leading glyph rendered before [label].
  final Widget? icon;

  /// Accessibility label. Defaults to [label] when omitted.
  final String? semanticLabel;

  /// Creates a segment for [OctoSegmentedControl].
  const OctoSegmentedControlItem({
    required this.value,
    this.label,
    this.icon,
    this.semanticLabel,
  }) : assert(
          label != null || icon != null,
          'A segment needs at least a label or an icon',
        );
}
