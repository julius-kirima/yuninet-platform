import 'package:flutter_test/flutter_test.dart';
import 'package:yuninet_platform/screens/login_page.dart';

void main() {
  testWidgets('Login button exists', (WidgetTester tester) async {
    await tester.pumpWidget(LoginPage());
    expect(find.text('Login'), findsOneWidget);
  });
}