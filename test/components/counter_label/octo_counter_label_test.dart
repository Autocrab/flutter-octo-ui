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
  group('OctoCounterLabel', () {
    testWidgets('renders the count as text', (tester) async {
      await _pump(tester, const OctoCounterLabel(7));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('standard variant uses neutral.muted background', (tester) async {
      await _pump(tester, const OctoCounterLabel(3));
      final theme = OctoThemeData.light();
      final container = tester.widget<Container>(find.byType(Container));
      final dec = container.decoration! as BoxDecoration;
      expect(dec.color, theme.colors.neutral.muted);
    });

    testWidgets('primary variant uses accent palette', (tester) async {
      await _pump(
        tester,
        const OctoCounterLabel(3, variant: OctoCounterLabelVariant.primary),
      );
      final theme = OctoThemeData.light();
      final container = tester.widget<Container>(find.byType(Container));
      final dec = container.decoration! as BoxDecoration;
      expect(dec.color, theme.colors.accent.muted);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.color, theme.colors.accent.fg);
    });

    testWidgets('maxDisplayed clamps oversized values with a + suffix', (tester) async {
      await _pump(tester, const OctoCounterLabel(150, maxDisplayed: 99));
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);
    });

    testWidgets('semanticLabel overrides the announced value', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoCounterLabel(42, semanticLabel: '42 unread notifications'),
      );
      final node = tester.getSemantics(find.byType(OctoCounterLabel));
      expect(node.label, '42 unread notifications');
      handle.dispose();
    });
  });
}
