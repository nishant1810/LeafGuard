import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardamom_leaves_disease_detector/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CardoDisDetectApp(),
      ),
    );

    // Wait for all animations/builds
    await tester.pumpAndSettle();

    expect(
      find.text('Cardamom Leaf Disease Detection'),
      findsOneWidget,
    );
  });
}
