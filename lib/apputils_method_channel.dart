import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'apputils_platform_interface.dart';
import 'src/apputils_exception.dart';

/// Method-channel implementation of [AppUtilsPlatform].
class MethodChannelAppUtils extends AppUtilsPlatform {
  static const String antiScrapingChannelName =
      'com.dootchi.apputils/anti_scraping';

  @visibleForTesting
  final MethodChannel antiScrapingChannel = const MethodChannel(
    antiScrapingChannelName,
  );

  @override
  Future<void> initializeAntiScraping(String cuid) {
    return _invoke<void>(
      antiScrapingChannel,
      'antiScraping.initialize',
      <String, Object?>{'cuid': cuid},
    );
  }

  @override
  Future<String> getAntiScrapingTicket() async {
    final ticket = await _invoke<String>(
      antiScrapingChannel,
      'antiScraping.getTicket',
    );
    if (ticket == null) {
      throw const AppUtilsException(
        code: 'invalid_response',
        message: 'The native anti-scraping SDK returned a null ticket.',
      );
    }
    return ticket;
  }

  @override
  Future<bool> reportAntiScrapingDeviceStatus(String label) async {
    return await _invoke<bool>(
          antiScrapingChannel,
          'antiScraping.reportDeviceStatus',
          <String, Object?>{'label': label},
        ) ??
        false;
  }

  Future<T?> _invoke<T>(
    MethodChannel channel,
    String method, [
    Object? arguments,
  ]) async {
    try {
      return await channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppUtilsException(
          code: error.code,
          message: error.message ?? 'Native AppUtils operation failed.',
          details: error.details,
        ),
        stackTrace,
      );
    }
  }
}
