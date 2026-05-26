import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

class _PR {
  final int number;
  final String title;
  final String author;
  final int comments;
  const _PR(this.number, this.title, this.author, this.comments);
}

const _rows = [
  _PR(42, 'Add tabs component', 'anna', 5),
  _PR(43, 'Fix timeline rail', 'bob', 2),
  _PR(44, 'Cut 0.6 release', 'cara', 0),
];

List<OctoDataColumn<_PR>> _columns() => [
      OctoDataColumn<_PR>(label: '#', text: (r) => '#${r.number}', width: 60),
      OctoDataColumn<_PR>(label: 'Title', text: (r) => r.title, sortable: true),
      OctoDataColumn<_PR>(label: 'Author', text: (r) => r.author),
      OctoDataColumn<_PR>(
        label: 'Comments',
        text: (r) => '${r.comments}',
        alignment: OctoDataColumnAlignment.end,
        sortable: true,
        width: 96,
      ),
    ];

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(
        data: OctoThemeData.light(),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 560, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('OctoDataTable', () {
    testWidgets('renders headers + all row cells', (tester) async {
      await _pump(
        tester,
        OctoDataTable<_PR>(columns: _columns(), rows: _rows),
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Add tabs component'), findsOneWidget);
      expect(find.text('Fix timeline rail'), findsOneWidget);
      expect(find.text('anna'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('tapping a sortable header calls onSortChanged(asc) first', (tester) async {
      final calls = <(int, OctoSortDirection)>[];
      await _pump(
        tester,
        OctoDataTable<_PR>(
          columns: _columns(),
          rows: _rows,
          onSortChanged: (i, d) => calls.add((i, d)),
        ),
      );
      await tester.tap(find.text('Title'));
      expect(calls, [(1, OctoSortDirection.asc)]);
    });

    testWidgets('clicking the active sort column cycles asc → desc → none', (tester) async {
      final calls = <OctoSortDirection>[];
      Widget build(OctoSortDirection dir) => OctoDataTable<_PR>(
            columns: _columns(),
            rows: _rows,
            sortColumnIndex: 1,
            sortDirection: dir,
            onSortChanged: (_, d) => calls.add(d),
          );

      await _pump(tester, build(OctoSortDirection.asc));
      await tester.tap(find.text('Title'));
      expect(calls.last, OctoSortDirection.desc);

      await _pump(tester, build(OctoSortDirection.desc));
      await tester.tap(find.text('Title'));
      expect(calls.last, OctoSortDirection.none);

      await _pump(tester, build(OctoSortDirection.none));
      await tester.tap(find.text('Title'));
      expect(calls.last, OctoSortDirection.asc);
    });

    testWidgets('non-sortable header ignores taps', (tester) async {
      final calls = <int>[];
      await _pump(
        tester,
        OctoDataTable<_PR>(
          columns: _columns(),
          rows: _rows,
          onSortChanged: (i, _) => calls.add(i),
        ),
      );
      await tester.tap(find.text('Author')); // sortable: false
      expect(calls, isEmpty);
    });

    testWidgets('onRowTap fires with the typed row', (tester) async {
      _PR? tapped;
      await _pump(
        tester,
        OctoDataTable<_PR>(
          columns: _columns(),
          rows: _rows,
          onRowTap: (r) => tapped = r,
        ),
      );
      await tester.tap(find.text('Fix timeline rail'));
      expect(tapped?.number, 43);
    });

    testWidgets('empty rows render the empty-state message', (tester) async {
      await _pump(
        tester,
        OctoDataTable<_PR>(
          columns: _columns(),
          rows: const [],
          emptyMessage: 'No PRs match the filter',
        ),
      );
      expect(find.text('No PRs match the filter'), findsOneWidget);
    });

    testWidgets('column.cell beats column.text when both are present', (tester) async {
      await _pump(
        tester,
        OctoDataTable<_PR>(
          rows: const [_PR(1, 't', 'a', 0)],
          columns: [
            OctoDataColumn<_PR>(
              label: 'Custom',
              text: (r) => 'plain',
              cell: (_, r) => Text('custom-${r.number}'),
            ),
          ],
        ),
      );
      expect(find.text('custom-1'), findsOneWidget);
      expect(find.text('plain'), findsNothing);
    });

    test('asserts when neither text nor cell is supplied', () {
      expect(
        () => OctoDataColumn<_PR>(label: 'broken'),
        throwsAssertionError,
      );
    });
  });
}
