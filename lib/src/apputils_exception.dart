/// A platform-independent error raised by an AppUtils capability.
final class AppUtilsException implements Exception {
  const AppUtilsException({
    required this.code,
    required this.message,
    this.details,
  });

  /// Stable machine-readable error code.
  final String code;

  /// Human-readable failure description.
  final String message;

  /// Optional native diagnostic data.
  final Object? details;

  @override
  String toString() => 'AppUtilsException($code, $message)';
}
