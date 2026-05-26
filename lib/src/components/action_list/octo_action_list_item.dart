import 'package:flutter/widgets.dart';

/// Visual emphasis of an [OctoActionListItem].
///
/// `defaultColor` is the regular row. `danger` tints the foreground with
/// `danger.fg` and is used for destructive actions ("Delete repository").
enum OctoActionListItemVariant {
  /// Regular row using `fg.defaultColor` for the label.
  defaultColor,

  /// Destructive action — label and icon tinted with `danger.fg`.
  danger,
}

/// Data describing one row in [OctoActionList].
///
/// Carries presentation hints (label, leading / trailing widgets, variant,
/// selected) and a tap handler. The corresponding RenderObject is built by
/// [OctoActionList], not by the data class itself.
@immutable
class OctoActionListItem {
  /// Primary row text.
  final String label;

  /// Optional explanatory line rendered under [label].
  final String? description;

  /// Leading widget (typically an icon).
  final Widget? leading;

  /// Trailing widget (icon, chevron, label, etc.).
  final Widget? trailing;

  /// Tap callback. `null` renders the row disabled and ignores input.
  final VoidCallback? onPressed;

  /// Marks the row as currently selected (used by menu / single-select).
  final bool selected;

  /// Visual emphasis tier. See [OctoActionListItemVariant].
  final OctoActionListItemVariant variant;

  /// Accessibility label. Defaults to [label] when omitted.
  final String? semanticLabel;

  /// Creates an action-list row.
  const OctoActionListItem({
    required this.label,
    this.description,
    this.leading,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.variant = OctoActionListItemVariant.defaultColor,
    this.semanticLabel,
  });
}
