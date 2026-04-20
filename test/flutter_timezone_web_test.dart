@TestOn('browser')
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('web plugin uses real JS interop for timezone data', () async {
    final plugin = FlutterTimezonePlugin();

    final local =
        await plugin.handleMethodCall(const MethodCall('getLocalTimezone'))
            as Map<String, Object?>;
    expect(local, isA<Map<String, Object?>>());
    final identifier = local['identifier'];
    expect(identifier is String && identifier.isNotEmpty, isTrue);
    expect(local['localizedName'], isNull);
    expect(local['locale'], isNull);

    final available =
        await plugin.handleMethodCall(const MethodCall('getAvailableTimezones'))
            as List<Map<String, Object?>>;
    expect(available, isA<List<Map<String, Object?>>>());
    final list = available;
    expect(list.isNotEmpty, isTrue);
    expect(
      list.every((value) {
        final id = value['identifier'];
        return id is String && id.isNotEmpty;
      }),
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
