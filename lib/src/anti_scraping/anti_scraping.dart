import '../../apputils_platform_interface.dart';

/// Device-risk and anti-scraping operations backed by the native DpSDK.
final class AntiScraping {
  const AntiScraping.internal();

  /// Initializes the native SDK.
  ///
  /// Calls are idempotent and serialized by the native implementation.
  Future<void> initialize() =>
      AppUtilsPlatform.instance.initializeAntiScraping();

  /// Returns the ticket that should be attached to the protected request.
  ///
  /// The SDK is initialized lazily if [initialize] was not called beforehand.
  Future<String> getTicket() =>
      AppUtilsPlatform.instance.getAntiScrapingTicket();

  /// Reports a device-status label.
  ///
  /// The supplied DpSDK exposes this operation on iOS only. Android returns
  /// `false` to keep the cross-platform API predictable.
  Future<bool> reportDeviceStatus(String label) {
    if (label.trim().isEmpty) {
      throw ArgumentError.value(label, 'label', 'Must not be empty.');
    }
    return AppUtilsPlatform.instance.reportAntiScrapingDeviceStatus(label);
  }
}
