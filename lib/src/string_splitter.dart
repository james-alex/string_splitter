import 'package:meta/meta.dart';
import './string_splitter_converter.dart';

/// A utility class with methods for splitting strings.
class StringSplitter {
  StringSplitter._();

  /// Splits [string] into parts, slicing the string at each occurrence
  /// of any of the [splitters]. [string] must not be `null`, [splitters]
  /// must not be `null` or empty.
  ///
  /// To exclude splitters from slicing, [delimiters] can be provided.
  /// [delimiters] can be provided as a [String], in which case, that
  /// [String] will be used as both the opening and closing delimiter.
  /// Or, as a [List<String>] with 2 children, the first child being the
  /// opening delimiter, and the second child being the closing delimiter.
  /// [delimiters] must not be empty if it is provided.
  ///
  /// If [removeSplitters] is `true`, each string part will be captured
  /// without the splitting character(s), if `false`, the splitter will
  /// be included with the part. [removeSplitters] must not be `null`.
  ///
  /// If [trimParts] is `true`, the parser will trim the whitespace around
  /// each part when they are captured. [trimParts] must not be `null`.
  ///
  /// ```dart
  ///   final String string = "1/ 2/ 3/ 4/ 5/ <6/ 7/ 8>/ 9/ 10";
  ///
  ///   final List<String> stringParts = StringSplitter.split(
  ///     string,
  ///     ['/'],
  ///     delimiters: [['<', '>']],
  ///     trimParts: true,
  ///   );
  ///
  ///   print(stringParts); // [1, 2, 3, 4, 5, <6/ 7/ 8>, 9, 10]
  /// ```
  static List<String> split(
    String string, {
    @required List<String> splitters,
    List<dynamic> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
  }) {
    assert(string != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        (delimiters.isNotEmpty &&
            delimiters.every((delimiter) =>
                delimiter is String ||
                (delimiter is List<String> && delimiter.length == 2))));
    assert(removeSplitters != null);
    assert(trimParts != null);

    return StringSplitterConverter(
      splitters,
      delimiters,
      removeSplitters,
      trimParts,
    ).convert(string);
  }

  /// For parsing long strings, [stream] splits [string] into chunks and
  /// streams the returned parts as each chunk is split.
  ///
  /// Splits [string] into parts, slicing the string at each occurrence
  /// of any of the [splitters]. [string] must not be `null`,
  /// [splitters] must not be `null` or empty.
  ///
  /// To exclude splitters from slicing, [delimiters] can be provided.
  /// [delimiters] can be provided as a [String], in which case, that
  /// [String] will be used as both the opening and closing delimiter.
  /// Or, as a [List<String>] with 2 children, the first child being the
  /// opening delimiter, and the second child being the closing delimiter.
  /// [delimiters] must not be empty if it is provided.
  ///
  /// If [removeSplitters] is `true`, each string part will be captured
  /// without the splitting character(s), if `false`, the splitter will
  /// be included with the part. [removeSplitters] must not be `null`.
  ///
  /// If [trimParts] is `true`, the parser will trim the whitespace around
  /// each part when they are captured. [trimParts] must not be `null`.
  ///
  /// [chunkSize] represents the number of characters in each chunk, it
  /// must not be `null` and must be `> 0`.
  static Stream<List<String>> stream(
    String string, {
    @required List<String> splitters,
    List<dynamic> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
    @required int chunkSize,
  }) {
    assert(string != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        (delimiters.isNotEmpty &&
            delimiters.every((delimiter) =>
                delimiter is String ||
                (delimiter is List<String> && delimiter.length == 2))));
    assert(removeSplitters != null);
    assert(trimParts != null);
    assert(chunkSize != null && chunkSize > 0);

    final List<String> chunks = chunk(string, chunkSize);

    final Stream<String> input = Stream.fromIterable(chunks);

    return input.transform(
      StringSplitterConverter(
        splitters,
        delimiters,
        removeSplitters,
        trimParts,
        chunks.length,
      ),
    );
  }

  /// Splits [string] into chunks, [chunkSize] characters in length.
  ///
  /// [string] must not be `null`.
  ///
  /// [chunkSize] must not be `null` and must be `> 0`.
  static List<String> chunk(String string, int chunkSize) {
    assert(string != null);
    assert(chunkSize != null && chunkSize > 0);

    final int chunkCount = (string.length / chunkSize).ceil();

    final List<String> chunks = List<String>(chunkCount);

    for (int i = 0; i < chunkCount; i++) {
      final int sliceStart = i * chunkSize;
      final int sliceEnd = sliceStart + chunkSize;
      chunks[i] = string.substring(
        sliceStart,
        (sliceEnd < string.length) ? sliceEnd : string.length,
      );
    }

    return chunks;
  }
}
