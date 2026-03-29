import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_timezone');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'getLocalTimezone',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (methodCall) async => methodCall.method == 'getLocalTimezone'
                ? <String, Object?>{
                    'identifier': 'Etc/UTC',
                    'localizedName': null,
                    'locale': null,
                  }
                : null,
          );

      expect(
        await FlutterTimezone.getLocalTimezone(),
        TimezoneInfo(identifier: 'Etc/UTC'),
      );
    },
  );

  test('getLocalTimezone parses structured timezone info', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'getLocalTimezone');
          expect(methodCall.arguments, 'en_US');
          return <String, Object?>{
            'identifier': 'America/Los_Angeles',
            'localizedName': 'Pacific Time',
            'locale': 'en_US',
          };
        });

    expect(
      await FlutterTimezone.getLocalTimezone('en_US'),
      TimezoneInfo(
        identifier: 'America/Los_Angeles',
        localizedName: (name: 'Pacific Time', locale: 'en_US'),
      ),
    );
  });

  test('getAvailableTimezones parses structured timezone info list', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'getAvailableTimezones');
          expect(methodCall.arguments, 'de');
          return <Object?>[
            <String, Object?>{
              'identifier': 'Europe/Berlin',
              'localizedName': 'Mitteleuropaeische Zeit',
              'locale': 'de',
            },
            <String, Object?>{
              'identifier': 'UTC',
              'localizedName': null,
              'locale': null,
            },
          ];
        });

    expect(
      await FlutterTimezone.getAvailableTimezones('de'),
      <TimezoneInfo>[
        TimezoneInfo(
          identifier: 'Europe/Berlin',
          localizedName: (name: 'Mitteleuropaeische Zeit', locale: 'de'),
        ),
        TimezoneInfo(identifier: 'UTC'),
      ],
    );
  });

  test('getLocalTimezone throws when platform returns null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async => null);

    await expectLater(
      FlutterTimezone.getLocalTimezone(),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('getAvailableTimezones throws when platform returns null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async => null);

    await expectLater(
      FlutterTimezone.getAvailableTimezones(),
      throwsA(isA<ArgumentError>()),
    );
  });
}
