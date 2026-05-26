import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    OctoTheme(
      data: OctoThemeData.light(),
      child: MaterialApp(home: Scaffold(body: Center(child: child))),
    ),
  );
}

void main() {
  group('OctoTooltip', () {
    testWidgets('renders the anchor child', (tester) async {
      await _pump(
        tester,
        const OctoTooltip(message: 'Save', child: Text('Save')),
      );
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows the tooltip on long press', (tester) async {
      await _pump(
        tester,
        const OctoTooltip(
          message: 'Tooltip body',
          // Wider target so the tester's long-press finds it reliably.
          child: SizedBox(width: 100, height: 40, child: Center(child: Text('hit'))),
        ),
      );

      // Initially the tooltip text is NOT in the tree.
      expect(find.text('Tooltip body'), findsNothing);

      final gesture = await tester.startGesture(tester.getCenter(find.text('hit')));
      await tester.pump(const Duration(milliseconds: 800));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Tooltip body'), findsOneWidget);
    });

    testWidgets('forwards triggerMode override', (tester) async {
      // Manual mode means hover/long-press do NOT auto-show.
      await _pump(
        tester,
        const OctoTooltip(
          message: 'manual',
          triggerMode: TooltipTriggerMode.manual,
          child: SizedBox(width: 100, height: 40, child: Center(child: Text('hit'))),
        ),
      );
      final gesture = await tester.startGesture(tester.getCenter(find.text('hit')));
      await tester.pump(const Duration(milliseconds: 800));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('manual'), findsNothing);
    });
  });
}
