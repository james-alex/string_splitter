# string_splitter

Utility classes for splitting strings and files into parts. Supports
streamed parsing for handling long strings and large files.

# Usage

string_splitter has 2 libraries: [string_splitter] for parsing strings, and
[string_splitter_io] for parsing files.

## string_splitter

```dart
import 'package:string_splitter/string_splitter.dart';
```

[StringSplitter] is a utility class with 3 methods: [split], [stream],
and [chunk].

[split] and [stream] accept [splitters], which defines the character(s)
to split the strings at, and [delimiters], which can be provided as a list
of [String]s and/or [Delimiter]s, to denote blocks of text which shouldn't
be parsed for [splitters].

### split

[split] synchronously splits the provided string at the provided[splitters]
and returns a `List<String>` containing the split parts.

__Note:__ [trimParts] can be set to `true` to trim the whitespace around the
returned parts.

```dart
final string = '1, 2, 3, 4, 5, <6, 7, 8>, 9, 10';

final stringParts = StringSplitter.split(
  string,
  splitters: [','],
  delimiters: [Delimiter('<', '>')],
  trimParts: true,
);

print(stringParts); // ['1', '2', '3', '4', '5', '<6, 7, 8>', '9', '10']
```

[split] can alternatively be used as an extension method on [String].

```dart
final string = '1, 2, 3, 4, 5, <6, 7, 8>, 9, 10';

final stringParts = string.split(
  splitters: [','],
  delimiters: [Delimiter('<', '>')],
  trimParts: true,
);

print(stringParts); // ['1', '2', '3', '4', '5', '<6, 7, 8>', '9', '10']
```

### stream

[stream] is intended for handling long strings; it splits the provided string
into chunks, streaming the resulting `List<String>`s as each chunk is parsed.

[chunkSize] must be provided, which defines the number of characters to limit
each chunk to.

```dart
final stream = StringSplitter.stream(
  string,
  chunkSize: 1000,
  splitters: [','],
  delimiters: [r'\'],
);

await for (List<String> parts in stream) {
  print(parts);
}
```

[stream] can alternatively be used as an extension method on [String],
referenced as [splitStream].

```dart
final stream = string.splitStream(
  chunkSize: 1000,
  splitters: [','],
  delimiters: [r'\'],
);

await for (List<String> parts in stream) {
  print(parts);
}
```

### chunk

[chunk] splits strings into chunks of a defined length, returned as a `List<String>`.

```dart
final chunks = StringSplitter.chunk(string, 1000);
```

[chunk] can alternatively be used as an extension method on [String].

```dart
final chunks = string.chunk(1000);
```

## string_splitter_io

```dart
import 'package:string_splitter/string_splitter_io.dart';
```

[StringSplitterIo] is a utility class with 3 methods: [split], [splitSync],
and [stream]; they function the same as [StringSplitter]'s methods, except
they accept [File]s instead of [String]s.

### split

[split] asynchronously reads the provided [File] as a string and splits it apart
at the provided [splitters] and returns a `Future<List<String>>` containing the
split parts when the it completes.

```dart
final file = File('path/to/file');
final stringParts = await StringSplitterIo.split(
  file,
  splitters: [','],
  delimiters: [Delimiter('<', '>')],
  trimParts: true,
);
```

[split] can alternatively be used as an extension method on [File].

```dart
final file = File('path/to/file');
final stringParts = await file.split(
  splitters: [','],
  delimiters: [Delimiter('<', '>')],
  trimParts: true,
);
```

### splitSync

[splitSync] synchronously reads the provided [File] as a string and splits it
apart, returning a `List<String>` containing the split parts.

```dart
final file = File('path/to/file');
final stringParts = StringSplitterIo.splitSync(
  file,
  splitters: [','],
  delimiters: [Delimiter('<', '>')],
  trimParts: true,
);
```

[splitSync] can alternatively be used as an extension method on [File].

```dart
final file = File('path/to/file');
final stringParts = file.splitSync(
  splitters: [','],
  delimiters: [Delimiter('<', '>')],
  trimParts: true,
);
```

### stream

[stream] is intended for splitting large files; it streams the contents of the
provided [File], splitting and returning the parsed chunks as they're read.

```dart
final file = File('path/to/file');
final stream = StringSplitterIo.stream(
  file,
  chunkSize: 1000,
  splitters: [','],
  delimiters: [r'\'],
);

await for (List<String> parts in stream) {
  print(parts);
}
```

[stream] can alternatively be used as an extension method on [File],
referenced as [splitStream].

```dart
final file = File('path/to/file');
final stream = file.splitStream(
  chunkSize: 1000,
  splitters: [','],
  delimiters: [r'\'],
);

await for (List<String> parts in stream) {
  print(parts);
}
```
