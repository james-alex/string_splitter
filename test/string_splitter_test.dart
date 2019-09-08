import 'package:test/test.dart';
import 'package:string_splitter/string_splitter.dart';
import 'package:string_splitter/string_splitter_io.dart';

void main() {
  test('Simple Split', () {
    final String string = "1/ 2/ 3/ 4/ 5/ \"6/ 7/ 8\"/ 9/ 10";

    final List<String> stringParts = StringSplitter.split(
       string,
       splitters: ['/'],
       delimiters: ['"'],
       trimParts: true,
     );

    expect(stringParts.length, equals(8));

    expect(stringParts[5], equals('"6/ 7/ 8"'));
  });

  // The tests below use modified version of timezonedb.com's database files.

  test('String Streaming', () async {
    final String testString = File('test/files/timezone.csv').readAsStringSync();

    final Stream<List<String>> stream = StringSplitter.stream(
      testString,
      splitters: ['/'],
      delimiters: ['"'],
      chunkSize: 5000,
    );

    int partsCount = 0;

    await for (List<String> chunk in stream) {
      partsCount += chunk.length;
    }

    expect(partsCount, equals(652037));
  });

  test('Parse From File', () async {
    final List<String> country = await StringSplitterIo.split(
      File('test/files/country.csv'),
      splitters: [',', '\n'],
      delimiters: ['"'],
    );

    expect(country.length, equals(498));

    country.forEach((String part) {
      expect(part.startsWith('"'), equals(true));
      expect(part.endsWith('"'), equals(true));
    });

    final List<String> zone = StringSplitterIo.splitSync(
      File('test/files/zone.csv'),
      splitters: ['/', '\n'],
      delimiters: ['"', ['<', '>']],
      trimParts: true,
    );

    expect(zone.length, equals(1275));

    for (int i = 0; i < zone.length; i++) {
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
    final Stream<List<String>> timezone = StringSplitterIo.stream(
      File('test/files/timezone.csv'),
      splitters: ['/'],
      delimiters: ['"'],
    );

    int partsCount = 0;

    await for (List<String> chunk in timezone) {
      partsCount += chunk.length;
    }

    expect(partsCount, equals(652037));
  });
}
