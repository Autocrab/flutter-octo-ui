import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: child),
    ),
  );
}

void main() {
  group('OctoActionList', () {
    testWidgets('renders every item label', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(label: 'New issue', onPressed: () {}),
            OctoActionListItem(label: 'New pull request', onPressed: () {}),
            OctoActionListItem(label: 'Settings', onPressed: () {}),
          ],
        ),
      );
      expect(find.text('New issue'), findsOneWidget);
      expect(find.text('New pull request'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('invokes onPressed on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoActionList(
          items: [OctoActionListItem(label: 'Tap me', onPressed: () => taps++)],
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(taps, 1);
    });

    testWidgets('null onPressed renders disabled and ignores taps', (tester) async {
      const taps = 0;
      await _pump(
        tester,
        const OctoActionList(
          items: [OctoActionListItem(label: 'Disabled')],
        ),
      );
      await tester.tap(find.text('Disabled'));
      expect(taps, 0);
      final node = tester.getSemantics(find.text('Disabled'));
      expect(node.getSemanticsData().flagsCollection.isEnabled, isFalse);
    });

    testWidgets('selected exposes selected flag in Semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(label: 'Picked', selected: true, onPressed: () {}),
          ],
        ),
      );
      final node = tester.getSemantics(find.text('Picked'));
      expect(node.getSemanticsData().flagsCollection.isSelected, isTrue);
      handle.dispose();
    });

    testWidgets('danger variant tints label with danger.fg', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(
              label: 'Delete repository',
              variant: OctoActionListItemVariant.danger,
              onPressed: () {},
            ),
          ],
        ),
      );
      final text = tester.widget<Text>(find.text('Delete repository'));
      expect(text.style!.color, OctoThemeData.light().colors.danger.fg);
    });

    testWidgets('description renders below label when present', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(
              label: 'Archive',
              description: 'Hide from default search results',
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Hide from default search results'), findsOneWidget);
    });

    testWidgets('.builder builds the right number of rows', (tester) async {
      await _pump(
        tester,
        SizedBox(
          height: 200,
          child: OctoActionList.builder(
            shrinkWrap: false,
            itemCount: 5,
            itemBuilder: (_, i) => OctoActionListItem(label: 'Item $i', onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });
  });
}
