import 'dart:developer' as dev;

import 'package:meta/meta.dart';

const _TAG = "Chat";

@immutable
abstract class AppLogger {
  /// This represents the default value of the logger active state.
  static bool _isActive = true;

  /// Changes the logger active state.
  ///
  /// if true, the logger will log messages.
  /// If false, the logger will not log messages.
  ///
  /// The default value is [_isActive].
  static set isActive(bool newValue) {
    _isActive = newValue;
  }

  /// Logs a message, if the logger is active.
  static void log(String message) {
    if (!_isActive) {
      return;
    }

    dev.log(
      message,
      name: _TAG,
    );
  }

  /// Logs that a request to an [endpoint] is being made, if the logger is active.
  static void logEndpoint(String endpoint) {
    log("accessing endpoint: $endpoint");
  }

  /// Logs that an api key is being set, if the logger is active.
  static void logAPIKey() {
    log("api key is set");
  }

  /// Logs that an baseUrl key is being set, if the logger is active.
  static void logBaseUrl() {
    log("baseUrl is set");
  }

  /// Logs that an organization id is being set, if the logger is active.
  static void logOrganization(String? organizationId) {
    log("organization id set to $organizationId");
  }
}
