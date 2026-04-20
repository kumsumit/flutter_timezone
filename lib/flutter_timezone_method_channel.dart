import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of the timezone plugin using MethodChannel.
class MethodChannelFlutterTimezone {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_timezone');

  /// Returns the platform version (for demonstration; not used in main API).
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  /// Returns the local timezone identifier or a structured map if supported.
  Future<dynamic> getLocalTimezone([String? locale]) async {
    final result = await methodChannel.invokeMethod('getLocalTimezone', locale);
    return result;
  }

  /// Returns a list of available timezone identifiers or structured maps if supported.
  Future<List<dynamic>> getAvailableTimezones([String? locale]) async {
    final result = await methodChannel.invokeListMethod(
      'getAvailableTimezones',
      locale,
    );
    return result ?? <dynamic>[];
  }
}
