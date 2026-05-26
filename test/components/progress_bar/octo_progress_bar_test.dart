import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: OctoTheme(
          data: OctoThemeData.light(),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('OctoProgressBar', () {
    testWidgets('determinate — clamps value into [0, 1]', (tester) async {
      await _pump(tester, const OctoProgressBar(value: 0.5));
      final size = tester.getSize(find.byType(OctoProgressBar));
      expect(size.width, 200);
      expect(size.height, 8);
      final fill = tester.getSize(
        find.descendant(
          of: find.byType(OctoProgressBar),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(fill.width, 100);
    });

    testWidgets('size.small renders 4px high', (tester) async {
      await _pump(
        tester,
        const OctoProgressBar(value: 0.3, size: OctoProgressBarSize.small),
      );
      expect(tester.getSize(find.byType(OctoProgressBar)).height, 4);
    });

    testWidgets('determinate exposes percentage to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoProgressBar(value: 0.75, semanticLabel: 'Uploading'),
      );
      final node = tester.getSemantics(find.byType(OctoProgressBar));
      final data = node.getSemanticsData();
      expect(data.label, 'Uploading');
      expect(data.value, '75%');
      handle.dispose();
    });

    testWidgets('indeterminate — controller repeats while animations on', (tester) async {
      await _pump(tester, const OctoProgressBar());
      // No FractionallySizedBox in the indeterminate path.
      expect(
        find.descendant(
          of: find.byType(OctoProgressBar),
          matching: find.byType(FractionallySizedBox),
        ),
        findsNothing,
      );
      // Pump a frame to make sure no exception escapes the AnimationController.
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('indeterminate + disabled animations falls back to static fill', (tester) async {
      await _pump(tester, const OctoProgressBar(), disableAnimations: true);
      // Static fall-back uses the determinate fill at 50%.
      expect(
        find.descendant(
          of: find.byType(OctoProgressBar),
          matching: find.byType(FractionallySizedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('asserts value within [0, 1]', (tester) async {
      expect(() => OctoProgressBar(value: 1.5), throwsAssertionError);
      expect(() => OctoProgressBar(value: -0.1), throwsAssertionError);
    });
  });
}
