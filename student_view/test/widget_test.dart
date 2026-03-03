import 'package:flutter_test/flutter_test.dart';
import 'package:student_view/app/app.dart';

void main() {
  testWidgets('Auth page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const InternshipApp());
    expect(find.text('实习通'), findsWidgets);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('注册'), findsOneWidget);
  });
}
