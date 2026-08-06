import 'package:apputils_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the anti-scraping example', (tester) async {
    await tester.pumpWidget(const AppUtilsExample());

    expect(find.text('AppUtils 示例'), findsOneWidget);
    expect(find.text('获取反扒 ticket'), findsOneWidget);
  });
}
