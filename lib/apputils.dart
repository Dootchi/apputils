library;

import 'src/anti_scraping/anti_scraping.dart';

export 'src/anti_scraping/anti_scraping.dart';
export 'src/apputils_exception.dart';

/// Capabilities that can be initialized by [AppUtils.initialize].
enum AppUtilsCapability {
  /// Device-risk ticket generation backed by DpSDK.
  antiScraping,
}

/// Entry point for the reusable native capabilities in this package.
///
/// Add future capabilities as their own facade next to [antiScraping] so that
/// callers do not depend on platform-channel details.
final class AppUtils {
  AppUtils._();

  /// Shared package instance.
  static final AppUtils instance = AppUtils._();

  /// Anti-scraping / device-risk capability.
  final AntiScraping antiScraping = const AntiScraping.internal();

  /// Eagerly initializes the requested [capabilities].
  ///
  /// Individual capabilities also initialize lazily when first used, so this
  /// method is optional. It is useful when an app wants failures to surface at
  /// startup instead of during its first request.
  Future<void> initialize({
    Set<AppUtilsCapability> capabilities = const {
      AppUtilsCapability.antiScraping,
    },
  }) async {
    for (final capability in capabilities) {
      switch (capability) {
        case AppUtilsCapability.antiScraping:
          await antiScraping.initialize();
      }
    }
  }
}
