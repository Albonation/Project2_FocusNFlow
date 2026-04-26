// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:focus_n_flow/main.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    final themeController = ThemeController();

    await tester.pumpWidget(
      MyApp(themeController: themeController),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
