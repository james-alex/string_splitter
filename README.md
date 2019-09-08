# string_splitter

Utility classes for splitting strings and files into parts. Supports
streamed parsing for handling long strings and large files.

# Usage

string_splitter has 2 libraries, [string_splitter] for parsing strings, and
[string_splitter_io] for parsing files.

## Parsing Strings

```dart
import 'package:string_splitter/string_splitter.dart';
```

[StringSplitter] contains 3 static methods: [split], [stream], and [chunk].

Each method accepts a [String] to split, and [split] and [stream] accept lists
of [splitters] and [delimiters] to be used to split the string, while [chunk]
splits strings into a set numbers of characters per chunk.

[delimiters], if provided, will instruct the parser to ignore [splitters]
contained within the delimiting characters. [delimiters] can be provided as
an individual string, in which case the same character(s) will be used as both
the opening and closing delimiters, or as a [List] containing 2 [String]s,
the first string will be used as the opening delimiter, and the second, the
closing delimiter.

```dart
// Delimiters must be a [String] or a [List<String>] with 2 children.
List<dynamic> delimiters = ['"', ['<', '>']];
```

[split] and [stream] have 2 other options, [removeSplitters] and [trimParts].
[removeSplitters], if `true`, will instruct the parser not to include the
splitting characters in the returned parts, and [trimParts], if `true`, will trim the whitespace around each captured part.

[stream] and [chunk] both have a required parameter, [chunkSize], to set the
number of characters to split each chunk into.

```dart
/// Splits [string] into parts, slicing the string at each occurrence
/// of any of the [splitters].
static List<String> split(
  String string, {
  @required List<String> splitters,
  List<dynamic> delimiters,
  bool removeSplitters = true,
  bool trimParts = false,
});

/// For parsing long strings, [stream] splits [string] into chunks and
/// streams the returned parts as each chunk is split.
static Stream<List<String>> stream(
  String string, {
  @required List<String> splitters,
  List<dynamic> delimiters,
  bool removeSplitters = true,
  bool trimParts = false,
  @required int chunkSize,
});

/// Splits [string] into chunks, [chunkSize] characters in length.
static List<String> chunk(String string, int chunkSize);
```

Streams return each set of parts in chunks, to capture the complete data set,
you'll have to add them into a combined list as they're parsed.

```dart
Stream<List<String>> stream = StringSplitter.stream(
  string,
  splitters: [','],
  delimiters: ['"'],
  chunkSize: 5000,
);

final List<String> parts = List<String>();

await for (List<String> chunk in stream) {
  parts.addAll(chunk);
}
```

## Parsing Files

```dart
import 'package:string_splitter/string_splitter_io.dart';
```

[StringSplitterIo] also contains 3 static methods: [split], [splitSync],
and [stream].

Rather than a [String] like [StringSplitter]'s methods, [StringSplitterIo]'s
accept a [File], the contents of which will be read and parsed.

In addition to the parameters described in the section above, each method also
has a parameter to set the file's encoding, or in stream's case the decoder
itself, which all default to `UTF8`.

```dart
/// Reads [file] as a string and splits it into parts, slicing the string
/// at each occurrence of any of the [splitters].
static Future<List<String>> split(
  File file, {
  @required List<String> splitters,
  List<dynamic> delimiters,
  bool removeSplitters = true,
  bool trimParts = false,
  Encoding encoding = utf8,
});

/// Synchronously reads [file] as a string and splits it into parts,
/// slicing the string at each occurrence of any of the [splitters].
static List<String> splitSync(
  File file, {
  @required List<String> splitters,
  List<dynamic> delimiters,
  bool removeSplitters = true,
  bool trimParts = false,
  Encoding encoding = utf8,
});

/// For parsing large files, [stream] streams the contents of [file]
/// and returns the split parts in chunks.
static Stream<List<String>> stream(
  File file, {
  @required List<String> splitters,
  List<dynamic> delimiters,
  bool removeSplitters = true,
  bool trimParts = false,
  Converter<List<int>, String> decoder,
});
```
