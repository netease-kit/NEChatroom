import 'package:flutter_test/flutter_test.dart';
import 'package:imchat_rebuild/app.dart';

void main() {
  testWidgets('home shell shows primary navigation', (tester) async {
    await tester.pumpWidget(const ImChatRebuildApp());
    expect(find.text('الغرف'), findsWidgets);
    expect(find.text('الرسائل'), findsOneWidget);
    expect(find.text('لحظات'), findsOneWidget);
    expect(find.text('أنا'), findsOneWidget);
  });
}
