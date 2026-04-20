import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone_platform_interface.dart';
import 'package:flutter_timezone/geonames_timezones.dart';
import 'package:flutter_timezone/timezone_info.dart';

export 'package:flutter_timezone/timezone_info.dart';

/// Returns all timezone identifiers for a given country code.
List<String> getTimezonesForCountry(String countryCode) {
  return geonamesTimezones
      .where((tz) => tz['countryCode'] == countryCode)
      .map((tz) => tz['timezoneId']!)
      .toList();
}

/// Returns a list of unique country codes for a given GMT offset (as string, e.g. '1.0').
List<String> getCountriesForOffset(String offset) {
  final countries = geonamesTimezones
      .where((tz) => tz['gmtOffset'] == offset)
      .map((tz) => tz['countryCode']!)
      .toSet()
      .toList();
  countries.sort();
  return countries;
}

/// Returns the country code for a given timezone identifier, or null if not found.
String? getCountryCodeForTimezone(String timezoneId) {
  final info = getTimezoneInfo(timezoneId);
  return info != null ? info['countryCode'] : null;
}

/// Returns all IANA timezone identifiers from GeoNames data.
List<String> getAllTimezones() {
  return geonamesTimezones
      .where(
        (tz) => tz['timezoneId'] != null && tz['timezoneId'] != 'TimeZoneId',
      )
      .map((tz) => tz['timezoneId']!)
      .toList();
}

/// Returns metadata for a given timezone identifier, or null if not found.
Map<String, String>? getTimezoneInfo(String id) {
  return geonamesTimezones
          .firstWhere((tz) => tz['timezoneId'] == id, orElse: () => {})
          .isNotEmpty
      ? geonamesTimezones.firstWhere((tz) => tz['timezoneId'] == id)
      : null;
}

///
/// Class for getting the native timezone.
///
class FlutterTimezone {
  /// Returns the platform version string from the native layer.
  static Future<String?> getPlatformVersion() {
    return FlutterTimezonePlatform.instance.getPlatformVersion();
  }

  static const MethodChannel _channel = MethodChannel('flutter_timezone');

  ///
  /// Returns local timezone from the native layer.
  ///
  /// On supported platforms (see README), you can optionally provide a locale code (e.g. "en_US", "de") to get the
  /// localized name of the timezone in that locale, if provided by the underlying platform.
  static Future<TimezoneInfo> getLocalTimezone([String? locale]) async {
    final localTimezone = await _channel.invokeMethod(
      'getLocalTimezone',
      locale,
    );
    if (localTimezone == null) {
      throw ArgumentError('Invalid return from platform getLocalTimezone()');
    }
    if (localTimezone is String) {
      return TimezoneInfo(identifier: localTimezone);
    }
    return TimezoneInfo.fromJson(localTimezone);
  }

  ///
  /// Gets the list of available timezones from the native layer.
  ///
  /// On supported platforms (see README), you can optionally provide a locale code (e.g. "en_US", "de") to get the
  /// localized names of the timezones in that locale, if provided by the underlying platform.
  static Future<List<TimezoneInfo>> getAvailableTimezones([
    String? locale,
  ]) async {
    final availableTimezones = await _channel.invokeListMethod(
      'getAvailableTimezones',
      locale,
    );
    if (availableTimezones == null) {
      throw ArgumentError(
        'Invalid return from platform getAvailableTimezones()',
      );
    }
    return availableTimezones.map((timezone) {
      if (timezone is String) {
        return TimezoneInfo(identifier: timezone);
      }
      return TimezoneInfo.fromJson(timezone);
    }).toList();
  }
}
