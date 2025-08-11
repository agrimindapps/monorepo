// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_receituagro/main.dart';

void main() {
  testWidgets('ReceitaAgro app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ReceitaAgroApp());

    // Verify that key elements are present
    expect(find.text('🧪 ReceitaAgro'), findsOneWidget);
    expect(find.text('ReceitaAgro'), findsOneWidget);
    expect(find.text('Em Desenvolvimento'), findsOneWidget);
    expect(find.text('Compêndio de pragas e receitas de defensivos agrícolas'), findsOneWidget);
    expect(find.byIcon(Icons.science), findsOneWidget);
  });
}
