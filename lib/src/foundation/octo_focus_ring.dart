import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';

/// Keyboard-focus ring drawn as an outline stroke around [child] (ADR-0006).
///
/// Visibility rules — common to both constructors:
///   * [enabled] is `true`,
///   * the nearest enclosing [Focus] reports `hasPrimaryFocus`,
///   * AND `FocusManager.instance.highlightMode` is
///     [FocusHighlightMode.traditional] — i.e. the user navigated by
///     keyboard, not mouse click.
///
/// Two rendering strategies:
///
///   * Default constructor — the ring lives in a non-clipping [Stack]
///     beside [child]. Cheap, no [Overlay] required, but the ring will be
///     cropped by any ancestor that clips (`ClipRect`, `ListView` items,
///     dialog content boxes).
///   * [OctoFocusRing.overlay] — the ring is rendered through
///     [OverlayPortal] in the root [Overlay], so it survives all ancestor
///     clips. Requires an enclosing [Overlay] (provided by [MaterialApp] /
///     [WidgetsApp] by default).
class OctoFocusRing extends StatefulWidget {
  /// Widget that owns the ring's geometry; the ring paints around it.
  final Widget child;

  /// Disables painting without removing the widget from the tree.
  final bool enabled;

  /// Corner rounding matching the [child]'s decoration.
  final BorderRadius? borderRadius;

  /// Stroke colour. Defaults to `theme.colors.accent.fg`.
  final Color? color;

  /// Stroke width in logical pixels.
  final double thickness;

  /// Pixels of separation between the [child] edge and the ring.
  final double offset;

  /// `true` when this ring should render through [OverlayPortal] so it
  /// survives ancestor clips. Set via [OctoFocusRing.overlay].
  final bool _useOverlay;

  /// Creates an inline focus ring that wraps [child] in a non-clipping
  /// [Stack]. Use [OctoFocusRing.overlay] when an ancestor may clip.
  const OctoFocusRing({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius,
    this.color,
    this.thickness = 2,
    this.offset = 2,
  }) : _useOverlay = false;

  /// Clip-proof focus ring rendered through [OverlayPortal] (ADR-0006).
  ///
  /// The ring is painted in the root [Overlay] and tracked to [child] via
  /// [CompositedTransformFollower], so it escapes every ancestor clip
  /// (lists, dialogs, scroll viewports). Requires an enclosing [Overlay].
  const OctoFocusRing.overlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius,
    this.color,
    this.thickness = 2,
    this.offset = 2,
  }) : _useOverlay = true;

  @override
  State<OctoFocusRing> createState() => _OctoFocusRingState();
}

class _OctoFocusRingState extends State<OctoFocusRing> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _targetKey = GlobalKey();
  Size _childSize = Size.zero;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusManagerChange);
    if (widget._useOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureSize());
    }
  }

  @override
  void didUpdateWidget(OctoFocusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._useOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureSize());
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusManagerChange);
    super.dispose();
  }

  void _onFocusManagerChange() {
    if (mounted) setState(() {});
  }

  void _captureSize() {
    if (!mounted) return;
    final rb = _targetKey.currentContext?.findRenderObject();
    if (rb is RenderBox && rb.hasSize) {
      final size = rb.size;
      if (size != _childSize) setState(() => _childSize = size);
    }
  }

  bool _computeVisible(BuildContext context) {
    final focus = Focus.maybeOf(context);
    final hasFocus = focus?.hasPrimaryFocus ?? false;
    final mode = FocusManager.instance.highlightMode;
    return widget.enabled && hasFocus && mode == FocusHighlightMode.traditional;
  }

  @override
  Widget build(BuildContext context) {
    final visible = _computeVisible(context);
    if (!widget._useOverlay) {
      return _buildInline(context, visible);
    }
    // Toggle portal next frame — `_portal.show/hide` cannot run during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (visible && !_portal.isShowing) _portal.show();
      if (!visible && _portal.isShowing) _portal.hide();
    });
    return _buildOverlay(context);
  }

  Widget _buildInline(BuildContext context, bool visible) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (visible)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RingPainter(
                  borderRadius: widget.borderRadius ?? BorderRadius.zero,
                  color: widget.color ?? OctoTheme.of(context).colors.accent.fg,
                  thickness: widget.thickness,
                  offset: widget.offset,
                  ringOutsideBounds: true,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _captureSize());
          return false;
        },
        child: SizeChangedLayoutNotifier(
          key: _targetKey,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: _buildOverlayRing,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayRing(BuildContext context) {
    if (_childSize == Size.zero) return const SizedBox.shrink();
    final color = widget.color ?? OctoTheme.of(context).colors.accent.fg;
    final offset = widget.offset;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        offset: Offset(-offset, -offset),
        child: IgnorePointer(
          child: SizedBox(
            width: _childSize.width + offset * 2,
            height: _childSize.height + offset * 2,
            child: CustomPaint(
              painter: _RingPainter(
                borderRadius: widget.borderRadius ?? BorderRadius.zero,
                color: color,
                thickness: widget.thickness,
                offset: offset,
                ringOutsideBounds: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color color;
  final double thickness;
  final double offset;
  final bool ringOutsideBounds;

  _RingPainter({
    required this.borderRadius,
    required this.color,
    required this.thickness,
    required this.offset,
    required this.ringOutsideBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Inline mode: SizedBox is the child's size; the ring spills outside.
    // Overlay mode: SizedBox is already inflated by `offset` on each side,
    // so the ring fills the canvas.
    final rect = ringOutsideBounds
        ? Rect.fromLTRB(-offset, -offset, size.width + offset, size.height + offset)
        : Offset.zero & size;
    final adjusted = BorderRadius.only(
      topLeft: Radius.elliptical(
        borderRadius.topLeft.x + offset,
        borderRadius.topLeft.y + offset,
      ),
      topRight: Radius.elliptical(
        borderRadius.topRight.x + offset,
        borderRadius.topRight.y + offset,
      ),
      bottomLeft: Radius.elliptical(
        borderRadius.bottomLeft.x + offset,
        borderRadius.bottomLeft.y + offset,
      ),
      bottomRight: Radius.elliptical(
        borderRadius.bottomRight.x + offset,
        borderRadius.bottomRight.y + offset,
      ),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawRRect(adjusted.toRRect(rect), paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.thickness != thickness ||
      oldDelegate.offset != offset ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.ringOutsideBounds != ringOutsideBounds;
}
