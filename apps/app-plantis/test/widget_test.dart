// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_plantis/main.dart';

void main() {
  testWidgets('Plantis app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlantisApp());

    // Verify that key elements are present
    expect(find.text('🌱 Plantis'), findsOneWidget);
    expect(find.text('Plantis'), findsOneWidget);
    expect(find.text('Em Desenvolvimento'), findsOneWidget);
    expect(find.text('Sistema de cuidados e lembretes para suas plantas'), findsOneWidget);
    expect(find.byIcon(Icons.eco), findsOneWidget);
  });
}
