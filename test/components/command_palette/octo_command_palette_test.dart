import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(
  WidgetTester tester, {
  required OctoCommandPaletteController controller,
  required List<OctoActionListItem> items,
  ShortcutActivator? openShortcut,
}) async {
  await tester.pumpWidget(
    OctoTheme(
      data: OctoThemeData.light(),
      child: MaterialApp(
        home: OctoCommandPalette(
          controller: controller,
          items: items,
          openShortcut: openShortcut,
          child: const Scaffold(
            body: Center(child: Text('app body')),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('OctoCommandPalette', () {
    testWidgets('starts closed; controller.open shows modal items', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        controller: controller,
        items: [
          OctoActionListItem(label: 'New issue', onPressed: () {}),
          OctoActionListItem(label: 'New pull request', onPressed: () {}),
        ],
      );

      expect(find.text('New issue'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('New issue'), findsOneWidget);
      expect(find.text('New pull request'), findsOneWidget);
    });

    testWidgets('filters items by query (case-insensitive substring)', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        controller: controller,
        items: [
          OctoActionListItem(label: 'Open settings', onPressed: () {}),
          OctoActionListItem(label: 'Close repository', onPressed: () {}),
          OctoActionListItem(label: 'Toggle dark mode', onPressed: () {}),
        ],
      );

      controller.open();
      await tester.pumpAndSettle();

      // The search field is autofocused — typing goes straight into it.
      await tester.enterText(find.byType(OctoTextField), 'sett');
      await tester.pumpAndSettle();

      expect(find.text('Open settings'), findsOneWidget);
      expect(find.text('Close repository'), findsNothing);
      expect(find.text('Toggle dark mode'), findsNothing);
    });

    testWidgets('empty query shows the no-match placeholder', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        controller: controller,
        items: [OctoActionListItem(label: 'Only thing', onPressed: () {})],
      );

      controller.open();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(OctoTextField), 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No matching commands'), findsOneWidget);
      expect(find.text('Only thing'), findsNothing);
    });

    testWidgets('Enter activates the first matching command and closes', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);
      var taps = 0;

      await _pump(
        tester,
        controller: controller,
        items: [
          OctoActionListItem(label: 'First', onPressed: () => taps++),
          OctoActionListItem(label: 'Second', onPressed: () {}),
        ],
      );

      controller.open();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(OctoTextField), 'first');
      await tester.pumpAndSettle();
      // `enterText` doesn't submit. Send Enter via the text input directly.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('Escape closes the palette', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        controller: controller,
        items: [OctoActionListItem(label: 'Item', onPressed: () {})],
      );

      controller.open();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(controller.isOpen, isFalse);
    });

    testWidgets('openShortcut opens the palette from a global keypress', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        controller: controller,
        items: [OctoActionListItem(label: 'Item', onPressed: () {})],
        openShortcut: const SingleActivator(LogicalKeyboardKey.keyK, meta: true),
      );

      expect(controller.isOpen, isFalse);
      // Simulate Meta+K (the cmd key on macOS bindings).
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      expect(controller.isOpen, isTrue);
    });

    testWidgets('tapping the dim scrim closes', (tester) async {
      final controller = OctoCommandPaletteController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        controller: controller,
        items: [OctoActionListItem(label: 'Item', onPressed: () {})],
      );

      controller.open();
      await tester.pumpAndSettle();
      // Top-left corner is on the scrim, outside the centered modal.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
    });
  });
}
