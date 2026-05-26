import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/components/data_table/octo_data_column.dart';
import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Sort state for a single column.
enum OctoSortDirection {
  /// Ascending (A → Z, low → high).
  asc,

  /// Descending (Z → A, high → low).
  desc,

  /// Not currently sorted by this column.
  none,
}

/// Density preset — controls vertical padding inside cells.
enum OctoDataTableDensity {
  /// Comfortable rows — readable for body content.
  comfortable,

  /// Compact rows — dense admin lists.
  compact,
}

/// Tabular data presenter (Primer "DataTable") generic over the row
/// type [T].
///
/// Columns are described via [OctoDataColumn] with a typed accessor or
/// custom cell builder. Headers can opt into sorting; the table itself
/// is *presentation only* — it does not reorder [rows] internally.
/// Wire [sortColumnIndex] / [sortDirection] + [onSortChanged] to the
/// parent and sort the underlying list there.
class OctoDataTable<T> extends StatelessWidget {
  /// Column descriptors. Order matters — left to right.
  final List<OctoDataColumn<T>> columns;

  /// Row data in display order.
  final List<T> rows;

  /// Active sort column (0-based) or `null` when unsorted.
  final int? sortColumnIndex;

  /// Current sort direction for [sortColumnIndex].
  final OctoSortDirection sortDirection;

  /// Fires when the user activates a sortable header. The receiver is
  /// expected to update its sort state and re-sort [rows].
  final void Function(int columnIndex, OctoSortDirection direction)? onSortChanged;

  /// Optional tap handler for a row — used to wire row-level
  /// navigation (open detail page).
  final void Function(T row)? onRowTap;

  /// When `true`, alternate rows use `neutral.subtle` background.
  final bool zebra;

  /// Density preset. See [OctoDataTableDensity].
  final OctoDataTableDensity density;

  /// Optional empty-state message rendered when [rows] is empty.
  final String emptyMessage;

  /// Creates a data table.
  const OctoDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortDirection = OctoSortDirection.none,
    this.onSortChanged,
    this.onRowTap,
    this.zebra = true,
    this.density = OctoDataTableDensity.comfortable,
    this.emptyMessage = 'No data',
  });

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));

    return Semantics(
      container: true,
      label: 'Data table',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border.muted),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                columns: columns,
                sortColumnIndex: sortColumnIndex,
                sortDirection: sortDirection,
                onSortChanged: onSortChanged,
                density: density,
                theme: theme,
              ),
              if (rows.isEmpty)
                _EmptyState(message: emptyMessage, theme: theme)
              else
                for (var i = 0; i < rows.length; i++)
                  _Row<T>(
                    columns: columns,
                    row: rows[i],
                    zebra: zebra && i.isOdd,
                    onTap: onRowTap == null ? null : () => onRowTap!(rows[i]),
                    isLast: i == rows.length - 1,
                    density: density,
                    theme: theme,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header<T> extends StatelessWidget {
  final List<OctoDataColumn<T>> columns;
  final int? sortColumnIndex;
  final OctoSortDirection sortDirection;
  final void Function(int columnIndex, OctoSortDirection direction)? onSortChanged;
  final OctoDataTableDensity density;
  final OctoThemeData theme;

  const _Header({
    required this.columns,
    required this.sortColumnIndex,
    required this.sortDirection,
    required this.onSortChanged,
    required this.density,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.canvas.subtle,
        border: Border(bottom: BorderSide(color: theme.colors.border.muted)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            _flex(
              columns[i],
              _HeaderCell<T>(
                column: columns[i],
                columnIndex: i,
                isSorted: sortColumnIndex == i,
                direction: sortDirection,
                onSortChanged: onSortChanged,
                density: density,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCell<T> extends StatefulWidget {
  final OctoDataColumn<T> column;
  final int columnIndex;
  final bool isSorted;
  final OctoSortDirection direction;
  final void Function(int columnIndex, OctoSortDirection direction)? onSortChanged;
  final OctoDataTableDensity density;
  final OctoThemeData theme;

  const _HeaderCell({
    required this.column,
    required this.columnIndex,
    required this.isSorted,
    required this.direction,
    required this.onSortChanged,
    required this.density,
    required this.theme,
  });

  @override
  State<_HeaderCell<T>> createState() => _HeaderCellState<T>();
}

class _HeaderCellState<T> extends State<_HeaderCell<T>> {
  late final WidgetStatesController _states;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _states.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  OctoSortDirection get _nextDirection {
    if (!widget.isSorted) return OctoSortDirection.asc;
    switch (widget.direction) {
      case OctoSortDirection.asc:
        return OctoSortDirection.desc;
      case OctoSortDirection.desc:
        return OctoSortDirection.none;
      case OctoSortDirection.none:
        return OctoSortDirection.asc;
    }
  }

  void _activate() {
    if (!widget.column.sortable) return;
    widget.onSortChanged?.call(widget.columnIndex, _nextDirection);
  }

  IconData? _sortIcon() {
    if (!widget.isSorted) return null;
    switch (widget.direction) {
      case OctoSortDirection.asc:
        return OctIcons.triangle_up_16;
      case OctoSortDirection.desc:
        return OctoSortDirection.desc == widget.direction ? OctIcons.triangle_down_16 : null;
      case OctoSortDirection.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final align = _mainAxisAlign(widget.column.alignment);
    final pad = _vPad(widget.density, widget.theme);
    final label = OctoText(
      widget.column.label,
      kind: OctoTextKind.bodyEmphasis,
      color: widget.theme.colors.fg.muted,
    );
    final icon = _sortIcon();
    final content = Row(
      mainAxisAlignment: align,
      children: [
        Flexible(child: label),
        if (icon != null) ...[
          SizedBox(width: widget.theme.spacing.gap.xs),
          Icon(icon, size: 12, color: widget.theme.colors.fg.muted),
        ],
      ],
    );

    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.theme.spacing.gap.md,
        vertical: pad,
      ),
      child: content,
    );

    if (!widget.column.sortable) {
      return ExcludeSemantics(child: padded);
    }

    return Semantics(
      button: true,
      label: '${widget.column.label}, sortable',
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        onShowHoverHighlight: (h) => _states.update(WidgetState.hovered, h),
        onShowFocusHighlight: (f) => _states.update(WidgetState.focused, f),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activate,
          child: ListenableBuilder(
            listenable: _states,
            builder: (_, __) {
              final focused = _states.value.contains(WidgetState.focused);
              return OctoFocusRing(
                enabled: focused,
                borderRadius: BorderRadius.zero,
                child: OctoStateLayer(
                  states: _states.value,
                  borderRadius: BorderRadius.zero,
                  child: padded,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Row<T> extends StatefulWidget {
  final List<OctoDataColumn<T>> columns;
  final T row;
  final bool zebra;
  final VoidCallback? onTap;
  final bool isLast;
  final OctoDataTableDensity density;
  final OctoThemeData theme;

  const _Row({
    required this.columns,
    required this.row,
    required this.zebra,
    required this.onTap,
    required this.isLast,
    required this.density,
    required this.theme,
  });

  @override
  State<_Row<T>> createState() => _RowState<T>();
}

class _RowState<T> extends State<_Row<T>> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController();
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = _vPad(widget.density, widget.theme);
    final body = Row(
      children: [
        for (final col in widget.columns)
          _flex(
            col,
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.theme.spacing.gap.md,
                vertical: pad,
              ),
              child: Align(
                alignment: _alignment(col.alignment),
                child: col.cell != null
                    ? col.cell!(context, widget.row)
                    : OctoText(
                        col.text!(widget.row),
                        color: widget.theme.colors.fg.defaultColor,
                      ),
              ),
            ),
          ),
      ],
    );

    final bg = widget.zebra ? widget.theme.colors.neutral.subtle : const Color(0x00000000);

    final decoratedBody = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: widget.isLast
            ? null
            : Border(
                bottom: BorderSide(color: widget.theme.colors.border.muted),
              ),
      ),
      child: body,
    );

    if (widget.onTap == null) {
      return decoratedBody;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _states.update(WidgetState.hovered, true),
      onExit: (_) => _states.update(WidgetState.hovered, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: ListenableBuilder(
          listenable: _states,
          builder: (_, __) => OctoStateLayer(
            states: _states.value,
            borderRadius: BorderRadius.zero,
            child: decoratedBody,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final OctoThemeData theme;

  const _EmptyState({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.gap.md,
        vertical: theme.spacing.gap.lg,
      ),
      child: Center(
        child: OctoText(message, color: theme.colors.fg.muted),
      ),
    );
  }
}

double _vPad(OctoDataTableDensity density, OctoThemeData theme) {
  switch (density) {
    case OctoDataTableDensity.comfortable:
      return theme.spacing.gap.sm;
    case OctoDataTableDensity.compact:
      return theme.spacing.scale(1);
  }
}

MainAxisAlignment _mainAxisAlign(OctoDataColumnAlignment a) {
  switch (a) {
    case OctoDataColumnAlignment.start:
      return MainAxisAlignment.start;
    case OctoDataColumnAlignment.center:
      return MainAxisAlignment.center;
    case OctoDataColumnAlignment.end:
      return MainAxisAlignment.end;
  }
}

AlignmentGeometry _alignment(OctoDataColumnAlignment a) {
  switch (a) {
    case OctoDataColumnAlignment.start:
      return AlignmentDirectional.centerStart;
    case OctoDataColumnAlignment.center:
      return Alignment.center;
    case OctoDataColumnAlignment.end:
      return AlignmentDirectional.centerEnd;
  }
}

Widget _flex<T>(OctoDataColumn<T> column, Widget child) {
  if (column.width != null) {
    return SizedBox(width: column.width, child: child);
  }
  return Expanded(flex: column.flex, child: child);
}
