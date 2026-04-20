import 'dart:convert';
import 'dart:io';

/// Downloads and parses the GeoNames timeZones.txt file.
/// Generates a Dart file with a list of timezone identifiers and their details.
/// Usage: dart tool/fetch_geonames_timezones.dart

const geonamesUrl = 'https://download.geonames.org/export/dump/timeZones.txt';
const outputFile = 'lib/geonames_timezones.dart';

Future<void> main() async {
  // print('Downloading $geonamesUrl ...');
  final response = await HttpClient().getUrl(Uri.parse(geonamesUrl));
  final result = await response.close();
  if (result.statusCode != 200) {
    stderr.writeln(
      'Failed to download GeoNames timeZones.txt: ${result.statusCode}',
    );
    exit(1);
  }
  final lines = await utf8.decoder.bind(result).toList();
  final content = lines.join();
  final timezones = <Map<String, String>>[];
  for (final line in LineSplitter.split(content)) {
    if (line.startsWith('#') || line.trim().isEmpty) continue;
    final parts = line.split('\t');
    if (parts.length < 3) continue;
    timezones.add({
      'countryCode': parts[0],
      'timezoneId': parts[1],
      'gmtOffset': parts[2],
      'dstOffset': parts.length > 3 ? parts[3] : '',
      'rawOffset': parts.length > 4 ? parts[4] : '',
    });
  }
  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Source: $geonamesUrl');
  buffer.writeln('const geonamesTimezones = [');
  for (final tz in timezones) {
    buffer.writeln('  {');
    buffer.writeln("    'countryCode': '${tz['countryCode']}',");
    buffer.writeln("    'timezoneId': '${tz['timezoneId']}',");
    buffer.writeln("    'gmtOffset': '${tz['gmtOffset']}',");
    buffer.writeln("    'dstOffset': '${tz['dstOffset']}',");
    buffer.writeln("    'rawOffset': '${tz['rawOffset']}',");
    buffer.writeln('  },');
  }
  buffer.writeln('];');
  await File(outputFile).writeAsString(buffer.toString());
  // print('Wrote timezone data to $outputFile');
}
