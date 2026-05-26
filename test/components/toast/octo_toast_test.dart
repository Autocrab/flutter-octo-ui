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

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(_harness(child));

void main() {
  group('OctoToast (inline)', () {
    testWidgets('renders the message + the variant icon', (tester) async {
      await _pump(
        tester,
        const OctoToast(
          message: 'Changes saved',
          variant: OctoToastVariant.success,
        ),
      );
      expect(find.text('Changes saved'), findsOneWidget);
      expect(find.byIcon(OctIcons.check_circle_16), findsOneWidget);
    });

    testWidgets('exposes a live-region semantics node', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoToast(message: 'Uploading attachment'));
      final data = tester.getSemantics(find.text('Uploading attachment')).getSemanticsData();
      expect(data.label.trim(), 'Uploading attachment');
      expect(data.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('action button + onDismiss button fire callbacks', (tester) async {
      var undid = 0;
      var dismissed = 0;
      await _pump(
        tester,
        OctoToast(
          message: 'Note archived',
          dismissible: true,
          onDismiss: () => dismissed++,
          action: OctoToastAction(label: 'Undo', onPressed: () => undid++),
        ),
      );
      await tester.tap(find.text('Undo'));
      expect(undid, 1);
      await tester.tap(find.byIcon(OctIcons.x_16));
      expect(dismissed, 1);
    });
  });

  group('OctoToast.show', () {
    Future<BuildContext> bootCtx(WidgetTester tester) async {
      late BuildContext captured;
      await _pump(
        tester,
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      );
      return captured;
    }

    testWidgets('mounts an overlay entry + auto-dismisses', (tester) async {
      final ctx = await bootCtx(tester);
      final controller = OctoToast.show(
        ctx,
        message: 'Saved',
        duration: const Duration(milliseconds: 500),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Saved'), findsOneWidget);
      expect(controller.isDismissed, isFalse);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Saved'), findsNothing);
      expect(controller.isDismissed, isTrue);
    });

    testWidgets('controller.dismiss removes the toast early', (tester) async {
      final ctx = await bootCtx(tester);
      final controller = OctoToast.show(
        ctx,
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
      final ctx = await bootCtx(tester);
      final controller = OctoToast.show(ctx, message: 'Sticky', duration: Duration.zero);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('Sticky'), findsOneWidget);
      controller.dismiss();
      await tester.pumpAndSettle();
    });
  });
}
