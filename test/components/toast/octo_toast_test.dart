import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    theme: OctoThemeData.light().toMaterialTheme(),
    home: OctoTheme(
      data: OctoThemeData.light(),
      child: Builder(builder: (context) => Scaffold(body: child)),
    ),
  );
}

void main() {
  group('OctoToast (inline)', () {
    testWidgets('renders the message + the variant icon', (tester) async {
      await tester.pumpWidget(_harness(
        const OctoToast(
          message: 'Changes saved',
          variant: OctoToastVariant.success,
        ),
      ));
      expect(find.text('Changes saved'), findsOneWidget);
      expect(find.byIcon(OctIcons.check_circle_16), findsOneWidget);
    });

    testWidgets('exposes a live-region semantics node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_harness(
        const OctoToast(message: 'Uploading attachment'),
      ));
      final data = tester
          .getSemantics(find.text('Uploading attachment'))
          .getSemanticsData();
      expect(data.label.trim(), 'Uploading attachment');
      expect(data.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('action button + onDismiss button fire callbacks',
        (tester) async {
      var undid = 0;
      var dismissed = 0;
      await tester.pumpWidget(_harness(
        OctoToast(
          message: 'Note archived',
          variant: OctoToastVariant.info,
          dismissible: true,
          onDismiss: () => dismissed++,
          action: OctoToastAction(label: 'Undo', onPressed: () => undid++),
        ),
      ));
      await tester.tap(find.text('Undo'));
      expect(undid, 1);
      await tester.tap(find.byIcon(OctIcons.x_16));
      expect(dismissed, 1);
    });
  });

  group('OctoToast.show', () {
    testWidgets('mounts an overlay entry + auto-dismisses', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_harness(
        Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      final controller = OctoToast.show(
        capturedContext,
        message: 'Saved',
        duration: const Duration(milliseconds: 500),
      );
      await tester.pump(); // mount overlay
      await tester.pump(const Duration(milliseconds: 250)); // settle slide-in
      expect(find.text('Saved'), findsOneWidget);
      expect(controller.isDismissed, isFalse);
      // Past the auto-dismiss timer + a full reverse animation cycle.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Saved'), findsNothing);
      expect(controller.isDismissed, isTrue);
    });

    testWidgets('controller.dismiss removes the toast early', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_harness(
        Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      final controller = OctoToast.show(
        capturedContext,
        message: 'Long-running task',
        duration: const Duration(seconds: 10),
      );
      await tester.pumpAndSettle();
      expect(find.text('Long-running task'), findsOneWidget);
      controller.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('Long-running task'), findsNothing);
      expect(controller.isDismissed, isTrue);
    });

    testWidgets('duration: zero disables auto-dismiss', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_harness(
        Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      final controller = OctoToast.show(
        capturedContext,
        message: 'Sticky',
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();
      // Pump way past any reasonable auto-dismiss.
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('Sticky'), findsOneWidget);
      controller.dismiss();
      await tester.pumpAndSettle();
    });
  });
}
