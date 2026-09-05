// Basic smoke test for the Meezan dashboard.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meezan/app/app.dart';

void main() {
  testWidgets('Dashboard renders the balance score and hub cards',
      (WidgetTester tester) async {
    // Use a tall surface so the whole scrolling dashboard lays out at once.
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: MeezanApp()));
    // Let the load animations settle.
    await tester.pumpAndSettle();

    // Spiritual + Productivity hub cards are present.
    expect(find.text('Spiritual Hub'), findsOneWidget);
    expect(find.text('Productivity Hub'), findsOneWidget);
    // The Morning Brief button is present.
    expect(find.text('Morning Brief'), findsWidgets);
  });
}
