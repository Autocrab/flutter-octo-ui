import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(
        data: OctoThemeData.light(),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 200, height: 200, child: child),
        ),
      ),
    ),
  );
}

Color? _resolvedColor(WidgetTester tester) {
  final colored = tester.widget<ColoredBox>(
    find.descendant(of: find.byType(OctoDivider), matching: find.byType(ColoredBox)),
  );
  return colored.color;
}

void main() {
  group('OctoDivider', () {
    testWidgets('horizontal — fills available width with 1px height', (tester) async {
      await _pump(tester, const Column(children: [OctoDivider()]));
      final box = tester.getSize(find.byType(OctoDivider));
      expect(box.width, 200);
      expect(box.height, 1);
    });

    testWidgets('vertical — fills available height with 1px width', (tester) async {
      await _pump(tester, const Row(children: [OctoDivider.vertical()]));
      final box = tester.getSize(find.byType(OctoDivider));
      expect(box.width, 1);
      expect(box.height, 200);
    });

    testWidgets('thickness overrides the line size', (tester) async {
      await _pump(
        tester,
        const Column(children: [OctoDivider(thickness: 4)]),
      );
      expect(tester.getSize(find.byType(OctoDivider)).height, 4);
    });

    testWidgets('indent/endIndent inset the painted region', (tester) async {
      await _pump(
        tester,
        const Column(children: [OctoDivider(indent: 16, endIndent: 24)]),
      );
      // Outer OctoDivider still spans full width — margin contributes back.
      expect(tester.getSize(find.byType(OctoDivider)).width, 200);
      // The painted stripe (the ColoredBox) is inset by the margins.
      final painted = tester.getSize(
        find.descendant(of: find.byType(OctoDivider), matching: find.byType(ColoredBox)),
      );
      expect(painted.width, 200 - 16 - 24);
    });

    testWidgets('emphasis maps onto theme.colors.border', (tester) async {
      final theme = OctoThemeData.light();
      for (final entry in {
        OctoDividerEmphasis.subtle: theme.colors.border.subtle,
        OctoDividerEmphasis.muted: theme.colors.border.muted,
        OctoDividerEmphasis.strong: theme.colors.border.defaultColor,
      }.entries) {
        await _pump(
          tester,
          Column(children: [OctoDivider(emphasis: entry.key)]),
        );
        expect(_resolvedColor(tester), entry.value);
      }
    });

    testWidgets('color overrides emphasis', (tester) async {
      const override = Color(0xFFFF00FF);
      await _pump(
        tester,
        const Column(children: [OctoDivider(color: override)]),
      );
      expect(_resolvedColor(tester), override);
    });
  });
}
