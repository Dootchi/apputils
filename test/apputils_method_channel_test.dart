import 'package:apputils/apputils.dart';
import 'package:apputils/apputils_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelAppUtils();
  const channel = MethodChannel(MethodChannelAppUtils.antiScrapingChannelName);
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'antiScraping.initialize' => null,
        'antiScraping.getTicket' => 'native-ticket',
        'antiScraping.reportDeviceStatus' => true,
        _ => throw MissingPluginException(),
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('uses the isolated anti-scraping channel contract', () async {
    await platform.initializeAntiScraping();
    expect(await platform.getAntiScrapingTicket(), 'native-ticket');
    expect(await platform.reportAntiScrapingDeviceStatus('login'), isTrue);

    expect(calls.map((call) => call.method), [
      'antiScraping.initialize',
      'antiScraping.getTicket',
      'antiScraping.reportDeviceStatus',
    ]);
    expect(calls.last.arguments, {'label': 'login'});
  });

  test('converts platform errors to AppUtilsException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
        code: 'sdk_unavailable',
        message: 'Unsupported ABI.',
      );
    });

    await expectLater(
      platform.getAntiScrapingTicket(),
      throwsA(
        isA<AppUtilsException>()
            .having((error) => error.code, 'code', 'sdk_unavailable')
            .having((error) => error.message, 'message', 'Unsupported ABI.'),
      ),
    );
  });
}
