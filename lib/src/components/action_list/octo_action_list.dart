import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/action_list/octo_action_list_item.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Vertical list of [OctoActionListItem]s — used standalone (e.g. inside a
/// drawer) or as the body of an overlay menu / popover (`OctoMenu`,
/// `OctoCommandPalette`).
///
/// Two construction modes:
///
///   * Default — accepts an in-memory `List<OctoActionListItem>`. Suitable
///     for short, fixed-size menus.
///   * [OctoActionList.builder] — lazy variant for long, scrollable lists
///     (filter dropdowns, command palettes, contact pickers). Mirrors
///     `ListView.builder` semantics.
///
/// Each row is its own focusable interactive surface with hover / pressed
/// state via [OctoStateLayer]; selection and the `danger` variant tint the
/// background and foreground accordingly. Keyboard arrow-key traversal is
/// deferred to a later milestone — for now, default Flutter focus
/// traversal applies.
class OctoActionList extends StatelessWidget {
  /// Eager list of items. Mutually exclusive with [itemCount] / [itemBuilder].
  final List<OctoActionListItem>? items;

  /// Item count for the lazy [OctoActionList.builder] variant.
  final int? itemCount;

  /// Item builder for the lazy [OctoActionList.builder] variant.
  final OctoActionListItem Function(BuildContext context, int index)? itemBuilder;

  /// Constrains the list to its intrinsic height. When `true` (default),
  /// the list does NOT scroll — useful inside a menu or a `Column`. Set to
  /// `false` to make the list scroll within its parent's constraints (e.g.
  /// inside a fixed-height popover).
  final bool shrinkWrap;

  /// Creates an action list backed by an eager [items] list.
  const OctoActionList({
    super.key,
    required List<OctoActionListItem> this.items,
    this.shrinkWrap = true,
  })  : itemCount = null,
        itemBuilder = null;

  /// Lazy variant — items are built on demand. Use for long lists where
  /// rendering every row upfront would be wasteful.
  const OctoActionList.builder({
    super.key,
    required int this.itemCount,
    required OctoActionListItem Function(BuildContext context, int index) this.itemBuilder,
    this.shrinkWrap = true,
  }) : items = null;

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    if (items != null) {
      return Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items!) _ActionRow(item: item, theme: theme),
        ],
      );
    }
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (ctx, index) => _ActionRow(item: itemBuilder!(ctx, index), theme: theme),
    );
  }
}

class _ActionRow extends StatefulWidget {
  final OctoActionListItem item;
  final OctoThemeData theme;

  const _ActionRow({required this.item, required this.theme});

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.item.onPressed == null) WidgetState.disabled,
      if (widget.item.selected) WidgetState.selected,
    });
  }

  @override
  void didUpdateWidget(_ActionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, widget.item.onPressed == null);
    _states.update(WidgetState.selected, widget.item.selected);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _enabled => widget.item.onPressed != null;

  Color _foreground(OctoThemeData theme, Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return theme.colors.fg.muted;
    if (widget.item.variant == OctoActionListItemVariant.danger) {
      return theme.colors.danger.fg;
    }
    return theme.colors.fg.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.item.selected,
      label: widget.item.semanticLabel ?? widget.item.label,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: _enabled ? (_) => _states.update(WidgetState.hovered, true) : null,
        onExit: _enabled ? (_) => _states.update(WidgetState.hovered, false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _states.update(WidgetState.pressed, true) : null,
          onTapUp: _enabled ? (_) => _states.update(WidgetState.pressed, false) : null,
          onTapCancel: _enabled ? () => _states.update(WidgetState.pressed, false) : null,
          onTap: _enabled ? widget.item.onPressed : null,
          child: ListenableBuilder(
            listenable: _states,
            builder: (context, _) {
              final states = _states.value;
              final fg = _foreground(theme, states);
              return OctoStateLayer(
                states: states,
                borderRadius: BorderRadius.all(Radius.circular(theme.radii.small)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.gap.md,
                    vertical: theme.spacing.gap.sm,
                  ),
                  child: Row(
                    children: [
                      if (widget.item.leading != null) ...[
                        IconTheme(
                          data: IconThemeData(color: fg, size: 16),
                          child: widget.item.leading!,
                        ),
                        SizedBox(width: theme.spacing.gap.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OctoText(widget.item.label, color: fg),
                            if (widget.item.description != null)
                              OctoText(
                                widget.item.description!,
                                kind: OctoTextKind.bodySmall,
                                color: theme.colors.fg.muted,
                              ),
                          ],
                        ),
                      ),
                      if (widget.item.trailing != null) ...[
                        SizedBox(width: theme.spacing.gap.md),
                        IconTheme(
                          data: IconThemeData(color: fg, size: 16),
                          child: widget.item.trailing!,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
