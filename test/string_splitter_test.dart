import 'package:test/test.dart';
import 'package:string_splitter/string_splitter.dart';
import 'package:string_splitter/string_splitter_io.dart';

void main() {
  test('Simple Split', () {
    final string = '1/ 2/ 3/ 4/ 5/ \'6/ 7/ 8\'/ 9/ 10';

    final stringParts = StringSplitter.split(
      string,
      splitters: ['/'],
      delimiters: ['\''],
      trimParts: true,
    );

    expect(stringParts.length, equals(8));

    expect(stringParts[5], equals('\'6/ 7/ 8\''));
  });

  // The tests below use modified version of timezonedb.com's database files.

  test('String Streaming', () async {
    final testString = File('test/files/timezone.csv').readAsStringSync();

    final stream = StringSplitter.stream(
      testString,
      splitters: ['/'],
      delimiters: ['"'],
      chunkSize: 5000,
    );

    var partsCount = 0;

    await for (List<String> chunk in stream) {
      partsCount += chunk.length;
    }

    expect(partsCount, equals(652037));
  });

  test('Parse From File', () async {
    final country = await StringSplitterIo.split(
      File('test/files/country.csv'),
      splitters: [',', '\r\n', '\n'],
      delimiters: ['"'],
    );

    expect(country.length, equals(498));

    for (var part in country) {
      //print('$part: ${part[part.length - 1]}');
      expect(part.startsWith('"'), equals(true));
      expect(part.endsWith('"'), equals(true));
    }

    final zone = StringSplitterIo.splitSync(
      File('test/files/zone.csv'),
      splitters: ['/', '\n'],
      delimiters: [
        '"',
        Delimiter('<', '>'),
      ],
      trimParts: true,
    );

    expect(zone.length, equals(1275));

    for (var i = 0; i < zone.length; i++) {
      switch (i % 3) {
        case 0:
          expect(zone[i].contains(RegExp(r'[0-9]{0,3}')), equals(true));
          break;
        case 1:
          expect(zone[i].contains(RegExp(r'"([A-Z]{2}/){1,2}[A-Z]{2}"')),
              equals(true));
          break;
        case 2:
          expect(zone[i].contains(RegExp('<(?:.*?\/){1,2}.*?>')), equals(true));
          break;
      }

      if (i == zone.length - 1) {
        expect(zone[i].endsWith('\n'), equals(false));
      }
    }
  });

  test('Stream From File', () async {
    final timezone = StringSplitterIo.stream(
      File('test/files/timezone.csv'),
      splitters: ['/'],
      delimiters: ['"'],
    );

    var partsCount = 0;

    await for (List<String> chunk in timezone) {
      partsCount += chunk.length;
    }

    expect(partsCount, equals(652037));
  });
}
