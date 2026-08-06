import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'apputils_method_channel.dart';

/// Platform contract for AppUtils capabilities.
///
/// Keep methods grouped by capability. A future federated platform package can
/// replace [instance] without changing the public facades.
abstract class AppUtilsPlatform extends PlatformInterface {
  AppUtilsPlatform() : super(token: _token);

  static final Object _token = Object();
  static AppUtilsPlatform _instance = MethodChannelAppUtils();

  static AppUtilsPlatform get instance => _instance;

  static set instance(AppUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initializeAntiScraping(String cuid) {
    throw UnimplementedError(
      'initializeAntiScraping() has not been implemented.',
    );
  }

  Future<String> getAntiScrapingTicket() {
    throw UnimplementedError(
      'getAntiScrapingTicket() has not been implemented.',
    );
  }

  Future<bool> reportAntiScrapingDeviceStatus(String label) {
    throw UnimplementedError(
      'reportAntiScrapingDeviceStatus() has not been implemented.',
    );
  }
}
