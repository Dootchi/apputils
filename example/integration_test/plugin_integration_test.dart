import 'package:apputils/apputils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native anti-scraping channel responds', (_) async {
    try {
      await AppUtils.instance.initialize(cuid: 'example-cuid');
      final ticket = await AppUtils.instance.antiScraping.getTicket();
      expect(ticket, isA<String>());
    } on AppUtilsException catch (error) {
      // Simulators do not contain a functional vendor SDK.
      expect(error.code, isIn(['sdk_unavailable', 'initialization_failed']));
    }
  });
}
