import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/main.dart';

void main() {
  testWidgets('Cosmos Insight home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CosmosInsightApp());
    await tester.pump();

    expect(find.text('Cosmos Insight'), findsOneWidget);
  });
}
