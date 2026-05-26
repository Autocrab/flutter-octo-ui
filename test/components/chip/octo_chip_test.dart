import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: Center(child: child)),
    ),
  );
}

void main() {
  group('OctoChip', () {
    testWidgets('renders the label', (tester) async {
      await _pump(tester, const OctoChip(label: 'frontend'));
      expect(find.text('frontend'), findsOneWidget);
    });

    testWidgets('no dismiss button when onDismiss is null', (tester) async {
      await _pump(tester, const OctoChip(label: 'tag'));
      expect(find.byIcon(OctIcons.x_16), findsNothing);
    });

    testWidgets('onDismiss adds a close button that fires on tap', (tester) async {
      var dismissed = 0;
      await _pump(
        tester,
        OctoChip(label: 'tag', onDismiss: () => dismissed++),
      );
      final closeIcon = find.byIcon(OctIcons.x_16);
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
      expect(dismissed, 1);
    });

    testWidgets('onPressed makes the chip tappable and fires on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoChip(label: 'filter', onPressed: () => taps++),
      );
      await tester.tap(find.text('filter'));
      expect(taps, 1);
    });

    testWidgets('non-interactive chip omits Semantics(button: true)', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoChip(label: 'tag'));
      final flags = tester.getSemantics(find.byType(OctoChip)).getSemanticsData().flagsCollection;
      expect(flags.isButton, isFalse);
      handle.dispose();
    });

    testWidgets('danger variant tints the label with danger.fg', (tester) async {
      await _pump(
        tester,
        const OctoChip(label: 'critical', variant: OctoChipVariant.danger),
      );
      final theme = OctoThemeData.light();
      final text = tester.widget<Text>(find.text('critical'));
      expect(text.style!.color, theme.colors.danger.fg);
    });
  });
}
