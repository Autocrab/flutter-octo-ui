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
@immutable
class OctoDataColumn<T> {
  /// Visible header label.
  final String label;

  /// Simple text accessor — receives one row, returns the cell text.
  final String Function(T row)? text;

  /// Widget builder — full control over the cell contents.
  final Widget Function(BuildContext context, T row)? cell;

  /// When `true`, the header becomes a tappable sort affordance and
  /// renders the current direction's chevron.
  final bool sortable;

  /// Horizontal alignment for both header and cell content.
  final OctoDataColumnAlignment alignment;

  /// Optional fixed width. When `null` the column flexes to fill.
  final double? width;

  /// Optional flex factor used when [width] is null. Defaults to 1.
  final int flex;

  /// Creates a column descriptor. At least one of [text] / [cell] must
  /// be supplied.
  const OctoDataColumn({
    required this.label,
    this.text,
    this.cell,
    this.sortable = false,
    this.alignment = OctoDataColumnAlignment.start,
    this.width,
    this.flex = 1,
  }) : assert(
          text != null || cell != null,
          'OctoDataColumn must define either `text` or `cell`',
        );
}
