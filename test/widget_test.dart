import 'package:flutter_test/flutter_test.dart';
import 'package:subkiller/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const SubKillerApp());
    expect(find.text('SubKiller'), findsOneWidget);
  });
}