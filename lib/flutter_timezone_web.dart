import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

///
/// The plugin class for the web, acts as the plugin inside bits
/// and connects to the js world.
///
class FlutterTimezonePlugin {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel('flutter_timezone', const StandardMethodCodec(), registrar);
    final instance = FlutterTimezonePlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getLocalTimezone':
        return _getLocalTimeZoneInfo();
      case 'getAvailableTimezones':
        return _getAvailableTimezoneInfos();
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The flutter_timezone plugin for web doesn't implement the method '${call.method}'");
    }
  }

  /// Platform-specific implementation of determining the user's
  /// local time zone when running on the web.
  ///
  String _getLocalTimeZone() {
    return _jsDateTimeFormat().resolvedOptions().timeZone;
  }

  Map<String, Object?> _getLocalTimeZoneInfo() {
    return <String, Object?>{
      'identifier': _getLocalTimeZone(),
      'localizedName': null,
      'locale': null,
    };
  }

  List<Map<String, Object?>> _getAvailableTimezoneInfos() {
    final intl = globalContext.getProperty<JSObject?>('Intl'.toJS);
    if (intl == null || !intl.hasProperty('supportedValuesOf'.toJS).toDart) {
      return <Map<String, Object?>>[_getLocalTimeZoneInfo()];
    }

    final timezones = _supportedValuesOf('timeZone'.toJS);
    if (timezones == null) {
      return <Map<String, Object?>>[_getLocalTimeZoneInfo()];
    }

    return timezones.toDart
        .map(
          (timezone) => <String, Object?>{
            'identifier': timezone.toDart,
            'localizedName': null,
            'locale': null,
          },
        )
        .toList();
  }
}

@JS('Intl.supportedValuesOf')
external JSArray<JSString>? _supportedValuesOf(JSString value);

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
