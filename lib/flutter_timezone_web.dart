import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

///
/// The plugin class for the web, acts as the plugin inside bits
/// and connects to the js world.
///
class FlutterTimezonePlugin {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'flutter_timezone',
      const StandardMethodCodec(),
      registrar,
    );
    final instance = FlutterTimezonePlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getLocalTimezone':
        return _getLocalTimeZoneInfo(call.arguments);
      case 'getAvailableTimezones':
        return _getAvailableTimezoneInfos(call.arguments);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              "The flutter_timezone plugin for web doesn't implement the method '{call.method}'",
        );
    }
  }

  /// Platform-specific implementation of determining the user's
  /// local time zone when running on the web.
  ///

  Map<String, Object?> _getLocalTimeZoneInfo([dynamic localeArg]) {
    final identifier = _jsDateTimeFormat().resolvedOptions().timeZone;
    // Web does not support localizedName or locale, so return null for those fields
    return {'identifier': identifier, 'localizedName': null, 'locale': null};
  }

  List<Map<String, Object?>> _getAvailableTimezoneInfos([dynamic localeArg]) {
    final values = supportedValuesOf('timeZone'.toJS);
    if (values == null) {
      return [_getLocalTimeZoneInfo(localeArg)];
    }
    return values.toDart
        .map(
          (value) => {
            'identifier': value.toDart,
            'localizedName': null,
            'locale': null,
          },
        )
        .toList();
  }
}

@JS('Intl.supportedValuesOf')
external JSArray<JSString>? supportedValuesOf(JSString value);

@JS('Intl.DateTimeFormat')
external _JSDateTimeFormat _jsDateTimeFormat();

@JS('Intl.DateTimeFormat.prototype')
@staticInterop
abstract class _JSDateTimeFormat {}

extension on _JSDateTimeFormat {
  @JS()
  external _JSResolvedOptions resolvedOptions();
}

@JS()
@staticInterop
abstract class _JSResolvedOptions {}

extension on _JSResolvedOptions {
  @JS()
  external String get timeZone;
}
