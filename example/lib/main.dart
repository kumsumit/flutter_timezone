import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _countryForCurrentTz;
  List<String> _timezonesForCountry = [];
  List<String> _countriesForOffset = [];
  final String _exampleCountry = 'IN';
  final String _exampleOffset = '5.5';
  TimezoneInfo? _timezone;
  List<TimezoneInfo> _availableTimezones = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _timezone = await FlutterTimezone.getLocalTimezone();
    _availableTimezones = await FlutterTimezone.getAvailableTimezones();
    _availableTimezones.sort((a, b) => a.identifier.compareTo(b.identifier));

    // Example: get country for current timezone
    _countryForCurrentTz = _timezone != null
        ? getCountryCodeForTimezone(_timezone!.identifier)
        : null;

    // Example: get all timezones for a country (e.g., 'IN')
    _timezonesForCountry = getTimezonesForCountry(_exampleCountry);

    // Example: get all countries for a GMT offset (e.g., '5.5')
    _countriesForOffset = getCountriesForOffset(_exampleOffset);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _initData,
          child: const Icon(Icons.refresh),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: <Widget>[
              Text(
                'Local Time Zone',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${_timezone?.identifier ?? 'Unknown'} - ${_timezone?.localizedName?.name ?? 'Unknown'}',
                key: const ValueKey('timeZoneLabel'),
              ),
              Text(
                'Country for local timezone: ${_countryForCurrentTz ?? "..."}',
              ),
              const SizedBox(height: 16),
              Text('All timezones for country ($_exampleCountry):'),
              ..._timezonesForCountry.map((tz) => Text(tz)).toList(),
              const SizedBox(height: 16),
              Text('Countries for GMT offset ($_exampleOffset):'),
              ..._countriesForOffset.map((cc) => Text(cc)).toList(),
              const SizedBox(height: 16),
              Text(
                'Available Time Zones (${_availableTimezones.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _availableTimezones.length,
                  itemBuilder: (_, index) {
                    final info = _availableTimezones[index];
                    return Text(
                      '${info.identifier} - ${info.localizedName?.name ?? 'Unknown'}',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
