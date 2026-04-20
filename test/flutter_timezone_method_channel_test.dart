import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_timezone');
  final plugin = MethodChannelFlutterTimezone();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion returns expected value', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'getPlatformVersion');
          return 'Android 13';
        });
    final version = await plugin.getPlatformVersion();
    expect(version, 'Android 13');
  });

  test('getLocalTimezone returns expected identifier', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'getLocalTimezone');
          return 'Asia/Kolkata';
        });
    final result = await channel.invokeMethod<String>('getLocalTimezone');
    expect(result, 'Asia/Kolkata');
  });

  test('getAvailableTimezones returns expected list', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'getAvailableTimezones');
          return <String>['Asia/Kolkata', 'Europe/London', 'America/New_York'];
        });
    final result = await channel.invokeListMethod<String>(
      'getAvailableTimezones',
    );
    expect(
      result,
      containsAll(['Asia/Kolkata', 'Europe/London', 'America/New_York']),
    );
    expect(result!.length, 3);
  });
}
