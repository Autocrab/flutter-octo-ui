import 'package:flutter/material.dart' show Tooltip, TooltipTriggerMode;
import 'package:flutter/widgets.dart';

/// Hover / long-press text tooltip.
///
/// Thin wrapper over Material's [Tooltip] — the heavy lifting (showing on
/// hover after a delay, on long press for touch, hiding on exit, smart
/// edge-flip, accessibility announcement) is already correct in Material.
/// What we control is the visual: padding, radius, colours, typography —
/// all driven by the `TooltipThemeData` that
/// `OctoThemeData.toMaterialTheme()` installs (ADR-0004).
class OctoTooltip extends StatelessWidget {
  /// Plain-text message shown on hover or long press.
  final String message;

  /// Widget the tooltip is anchored to.
  final Widget child;

  /// Forces show/hide programmatically; pass a [TooltipTriggerMode] value.
  /// When `null`, default behaviour applies (`longPress` on touch, `hover`
  /// elsewhere).
  final TooltipTriggerMode? triggerMode;

  /// Wraps [child] with a themed tooltip showing [message].
  const OctoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: triggerMode,
      child: child,
    );
  }
}
