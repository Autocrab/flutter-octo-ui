import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

class _Probe extends StatelessWidget {
  final FocusNode node;

  const _Probe({required this.node});

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: node,
      child: const OctoFocusRing(
        child: SizedBox(width: 80, height: 32),
      ),
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: child),
    ),
  );
}

void main() {
  group('OctoFocusRing', () {
    testWidgets('does NOT show without focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, _Probe(node: node));
      expect(find.byType(CustomPaint), findsNothing);
    });

    testWidgets('shows when focused under keyboard highlight mode', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, _Probe(node: node));

      node.requestFocus();
      await tester.pumpAndSettle();

      expect(
        node.hasPrimaryFocus,
        isTrue,
        reason: 'precondition: node should have primary focus',
      );
      expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('hides when highlight mode is touch', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, _Probe(node: node));

      node.requestFocus();
      await tester.pump();

      expect(find.byType(CustomPaint), findsNothing);
    });

    testWidgets('hides when enabled=false even with focus', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        Focus(
          focusNode: node,
          child: const OctoFocusRing(
            enabled: false,
            child: SizedBox(width: 80, height: 32),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(find.byType(CustomPaint), findsNothing);
    });
  });

  group('OctoFocusRing.overlay', () {
    Future<void> pumpOverlay(WidgetTester tester, Widget body) async {
      await tester.pumpWidget(
        OctoTheme(
          data: OctoThemeData.light(),
          child: MaterialApp(home: Scaffold(body: Center(child: body))),
        ),
      );
    }

    testWidgets('does NOT show without focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpOverlay(
        tester,
        Focus(
          focusNode: node,
          child: const OctoFocusRing.overlay(child: SizedBox(width: 80, height: 32)),
        ),
      );
      // Inline ring would create a CustomPaint child of OctoFocusRing; the
      // overlay variant only inserts CustomPaint into the Overlay when shown.
      expect(
        find.byType(CustomPaint).evaluate().any((e) {
          return e.findAncestorWidgetOfExactType<OctoFocusRing>() != null;
        }),
        isFalse,
      );
    });

    testWidgets('shows when focused under keyboard highlight mode', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpOverlay(
        tester,
        Focus(
          focusNode: node,
          child: const OctoFocusRing.overlay(child: SizedBox(width: 80, height: 32)),
        ),
      );

      node.requestFocus();
      await tester.pumpAndSettle();

      expect(node.hasPrimaryFocus, isTrue);
      // CompositedTransformFollower is only inserted by the overlay-mode ring.
      expect(find.byType(CompositedTransformFollower), findsOneWidget);
    });

    testWidgets('hides when highlight mode is touch', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpOverlay(
        tester,
        Focus(
          focusNode: node,
          child: const OctoFocusRing.overlay(child: SizedBox(width: 80, height: 32)),
        ),
      );

      node.requestFocus();
      await tester.pumpAndSettle();
      expect(find.byType(CompositedTransformFollower), findsNothing);
    });

    testWidgets('ring escapes a clipping ancestor', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);

      // ClipRect tightly hugging the child: an inline ring would be cropped
      // to the child's bounds. The overlay variant must render through the
      // root Overlay, escaping this specific ClipRect ancestor.
      const clipKey = Key('test-clip');
      await pumpOverlay(
        tester,
        ClipRect(
          key: clipKey,
          child: SizedBox(
            width: 80,
            height: 32,
            child: Focus(
              focusNode: node,
              child: const OctoFocusRing.overlay(child: SizedBox.expand()),
            ),
          ),
        ),
      );

      node.requestFocus();
      await tester.pumpAndSettle();

      final follower = find.byType(CompositedTransformFollower);
      expect(follower, findsOneWidget);

      // OverlayPortal intentionally keeps the overlay child's *element*
      // parent inside the OverlayPortal subtree so InheritedWidget lookups
      // continue to work — meaning a widget-tree walk would still hit our
      // ClipRect ancestor. The clip-escape happens in the *render* tree:
      // the overlay child's RenderObject is reparented under the Overlay's
      // render subtree, bypassing the ClipRect's RenderClipRect.
      final clipRender = tester.renderObject<RenderObject>(find.byKey(clipKey));
      var cursor = tester.renderObject<RenderObject>(follower).parent;
      var underTestClip = false;
      while (cursor != null) {
        if (identical(cursor, clipRender)) {
          underTestClip = true;
          break;
        }
        cursor = cursor.parent;
      }
      expect(
        underTestClip,
        isFalse,
        reason: 'overlay ring render tree must NOT live underneath the test ClipRect',
      );
    });
  });
}
