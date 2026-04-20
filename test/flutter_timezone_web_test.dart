@TestOn('browser')
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('web plugin uses real JS interop for timezone data', () async {
    final plugin = FlutterTimezonePlugin();

    final local = await plugin.handleMethodCall(
      const MethodCall('getLocalTimezone'),
    );
    expect(local, isA<Map<String, Object?>>());
    expect((local['identifier'] as String).isNotEmpty, isTrue);
    expect(local['localizedName'], isNull);
    expect(local['locale'], isNull);

    final available = await plugin.handleMethodCall(
      const MethodCall('getAvailableTimezones'),
    );
    expect(available, isA<List<Map<String, Object?>>>());
    final list = available as List<Map<String, Object?>>;
    expect(list.isNotEmpty, isTrue);
    expect(
      list.every(
        (value) =>
            value['identifier'] != null &&
            (value['identifier'] as String).isNotEmpty,
      ),
      isTrue,
    );

    const stableSample = <String>[
      'Africa/Abidjan',
      'Africa/Accra',
      'Africa/Cairo',
      'Africa/Johannesburg',
      'America/New_York',
      'America/Chicago',
      'America/Denver',
      'America/Los_Angeles',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Europe/London',
      'Europe/Paris',
    ];
    for (final zone in stableSample) {
      expect(list.map((m) => m['identifier']), contains(zone));
    }
  });
}
