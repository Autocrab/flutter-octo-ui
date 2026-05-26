import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui_example/main.dart';

void main() {
  testWidgets('kitchen sink boots and renders title', (tester) async {
    await tester.pumpWidget(const KitchenSinkApp());
    // pumpAndSettle would hang — the sink ships an indeterminate
    // OctoProgressBar + animated skeletons. Pump a single frame past
    // the initial mount so the inherited MaterialApp's first build
    // resolves, then look at what's on screen.
    await tester.pump();
    expect(find.text('octo_ui kitchen sink'), findsOneWidget);
    expect(find.text('Labels'), findsOneWidget);
  });
}
