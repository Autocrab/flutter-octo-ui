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
  group('OctoFlash', () {
    testWidgets('renders message', (tester) async {
      await _pump(tester, const OctoFlash(message: 'Saved'));
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('danger variant uses danger.subtle background + danger.muted border',
        (tester) async {
      await _pump(
        tester,
        const OctoFlash(message: 'Failed', variant: OctoFlashVariant.danger),
      );
      final theme = OctoThemeData.light();
      final container = tester.widget<Container>(find.byType(Container));
      final dec = container.decoration! as BoxDecoration;
      expect(dec.color, theme.colors.danger.subtle);
      expect((dec.border! as Border).top.color, theme.colors.danger.muted);
    });

    testWidgets('exposes liveRegion via Semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoFlash(message: 'Saved'));
      final node = tester.getSemantics(find.byType(OctoFlash));
      expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('no dismiss button when onDismiss is null', (tester) async {
      await _pump(tester, const OctoFlash(message: 'Saved'));
      expect(find.byType(OctoIconButton), findsNothing);
    });

    testWidgets('onDismiss renders a close button and fires on tap', (tester) async {
      var dismissed = 0;
      await _pump(
        tester,
        OctoFlash(message: 'Saved', onDismiss: () => dismissed++),
      );
      expect(find.byType(OctoIconButton), findsOneWidget);
      await tester.tap(find.byType(OctoIconButton));
      expect(dismissed, 1);
    });

    testWidgets('dismiss button carries the configured semanticLabel', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoFlash(
          message: 'Saved',
          onDismiss: () {},
          dismissSemanticLabel: 'Close notification',
        ),
      );
      expect(
        tester.getSemantics(find.byType(OctoIconButton)).label,
        contains('Close notification'),
      );
      handle.dispose();
    });
  });
}
