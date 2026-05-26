import 'package:flutter/widgets.dart';

/// Horizontal alignment of cell content within a column.
enum OctoDataColumnAlignment {
  /// Align content to the leading edge (default).
  start,

  /// Centre content horizontally.
  center,

  /// Align content to the trailing edge — typical for numeric columns.
  end,
}

/// Column descriptor for [OctoDataTable].
///
/// Provide either [text] for a simple `T -> String` cell or [cell] for
/// a full widget builder (badges, links, embedded widgets). When both
/// are supplied, [cell] wins.
///
/// **Sizing model.** The underlying `Table` widget honours one of three
/// regimes per column, in priority order:
///   1. `width != null` → fixed pixel width.
///   2. `flex != null && flex > 0` → flex column. Multiple flex
///      columns share the leftover space proportionally.
///   3. Default → intrinsic — the column hugs the widest cell
///      (including the header). Numeric columns and short labels
///      land here automatically; no need to hand-tune widths.
@immutable
class OctoDataColumn<T> {
  /// Header label. Doubles as the accessibility name for the column,
  /// even when [header] supplies a different visible widget.
  final String label;

  /// Optional visible header widget — typically an icon. When `null`
  /// the table renders [label] as a `bodyEmphasis` text.
  final Widget? header;

  /// Simple text accessor — receives one row, returns the cell text.
  final String Function(T row)? text;

  /// Widget builder — full control over the cell contents.
  final Widget Function(BuildContext context, T row)? cell;

  /// When `true`, the header becomes a tappable sort affordance and
  /// renders the current direction's chevron.
  final bool sortable;

  /// Horizontal alignment for both header and cell content.
  final OctoDataColumnAlignment alignment;

  /// Optional fixed width. Highest-priority sizing — overrides [flex]
  /// and the intrinsic default.
  final double? width;

  /// Optional flex factor. Pass `1` to let the column share leftover
  /// horizontal space with other flex columns; leave `null` (the
  /// default) to let the column hug its widest cell.
  final int? flex;

  /// Creates a column descriptor. At least one of [text] / [cell] must
  /// be supplied.
  const OctoDataColumn({
    required this.label,
    this.header,
    this.text,
    this.cell,
    this.sortable = false,
    this.alignment = OctoDataColumnAlignment.start,
    this.width,
    this.flex,
  }) : assert(
          text != null || cell != null,
          'OctoDataColumn must define either `text` or `cell`',
        );
}
