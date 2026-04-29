import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/main.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the dashboard title is shown.
    expect(find.text('Dashboard'), findsAtLeast(1));
  });
}
