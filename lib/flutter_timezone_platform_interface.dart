import 'package:flutter_timezone/flutter_timezone_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterTimezonePlatform extends PlatformInterface {
  /// Constructs a FlutterTimezonePlatform.
  FlutterTimezonePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTimezonePlatform _instance = MethodChannelFlutterTimezone();

  /// The default instance of [FlutterTimezonePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTimezone].
  static FlutterTimezonePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTimezonePlatform] when
  /// they register themselves.
  static set instance(FlutterTimezonePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
