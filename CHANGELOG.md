## 1.0.5

- Replaced product-specific Android packages and Dart/Android/iOS channel names
  with `ai.socialapps.apputils` for reuse across applications.
- Updated the iOS worker queue name and example application identifiers.
- Kept the `apputils` Dart package and public `AppUtils` API unchanged.
- Aligned Dart, Android, and CocoaPods version declarations with the Git release.
- Upgrade the Git ref, refresh dependencies, and recompile the host application;
  direct native-class or channel consumers must migrate their references.

## 0.1.0

- Added an extensible capability-oriented Flutter plugin architecture.
- Added Android and iOS DpSDK anti-scraping integration.
- Added eager and lazy initialization, ticket retrieval, typed errors, and iOS
  device-status reporting.
- Added simulator-safe builds, documentation, example usage, and tests.
