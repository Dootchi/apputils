import 'package:apputils/apputils.dart';
import 'package:apputils/apputils_method_channel.dart';
import 'package:apputils/apputils_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppUtilsPlatform
    with MockPlatformInterfaceMixin
    implements AppUtilsPlatform {
  var initializationCount = 0;
  String ticket = 'test-ticket';
  String? initializedCuid;
  String? reportedLabel;

  @override
  Future<String> getAntiScrapingTicket() async => ticket;

  @override
  Future<void> initializeAntiScraping(String cuid) async {
    initializationCount += 1;
    initializedCuid = cuid;
  }

  @override
  Future<bool> reportAntiScrapingDeviceStatus(String label) async {
    reportedLabel = label;
    return true;
  }
}

void main() {
  final initialPlatform = AppUtilsPlatform.instance;
  late MockAppUtilsPlatform platform;

  setUp(() {
    platform = MockAppUtilsPlatform();
    AppUtilsPlatform.instance = platform;
  });

  tearDown(() {
    AppUtilsPlatform.instance = initialPlatform;
  });

  test('method channel is the default platform', () {
    expect(initialPlatform, isA<MethodChannelAppUtils>());
  });

  test('initialize delegates selected capabilities', () async {
    await AppUtils.instance.initialize(cuid: 'user-001');
    expect(platform.initializationCount, 1);
    expect(platform.initializedCuid, 'user-001');

    await AppUtils.instance.initialize(
      cuid: 'user-002',
      capabilities: const {},
    );
    expect(platform.initializationCount, 1);
  });

  test('initialize converts null cuid to empty string before delegating',
      () async {
    await AppUtils.instance.initialize(cuid: null);
    expect(platform.initializationCount, 1);
    expect(platform.initializedCuid, '');
  });

  test('initialize converts blank cuid to empty string before delegating',
      () async {
    await AppUtils.instance.initialize(cuid: '  ');
    expect(platform.initializationCount, 1);
    expect(platform.initializedCuid, '');
  });

  test('anti-scraping facade delegates ticket and report calls', () async {
    expect(await AppUtils.instance.antiScraping.getTicket(), 'test-ticket');
    expect(
      await AppUtils.instance.antiScraping.reportDeviceStatus('login'),
      isTrue,
    );
    expect(platform.reportedLabel, 'login');
  });

  test('device status rejects empty labels before crossing the channel', () {
    expect(
      () => AppUtils.instance.antiScraping.reportDeviceStatus('  '),
      throwsArgumentError,
    );
  });
}
