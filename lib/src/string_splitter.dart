import 'package:meta/meta.dart';
import 'string_splitter_converter.dart';

/// A utility class with methods for splitting strings.
class StringSplitter {
  StringSplitter._();

  /// {@template string_splitter.StringSplitter.split}
  ///
  /// Splits [string] into parts, slicing the string at each occurrence
  /// of any of the [splitters]. [string] must not be `null`, [splitters]
  /// must not be `null` or empty.
  ///
  /// {@endtemplate}
  ///
  /// {@template string_splitter.StringSplitter.split.parameters}
  ///
  /// __Note:__ If using a linebreak (`\n`) as a splitter, it's a good idea to
  /// include `\r\n` before `\n`, as Windows and various internet protocols
  /// will automatically replace linebreaks with `\r\n` for backwards
  /// compatibility with legacy platforms. Not doing so shouldn't cause any
  /// problems in most cases, but will leave strings with a hidden `\r`
  /// character. `\n\r` is also used as a line ending by some systems.
  ///
  /// [delimiters] can be provided as [String]s and/or [Delimiter]s to denote
  /// blocks of text that shouldn't be parsed for [splitters].
  ///
  /// If [removeSplitters] is `true`, each string part will be captured
  /// without the splitting character(s), if `false`, the splitter will
  /// be included with the part. [removeSplitters] must not be `null`.
  ///
  /// If [trimParts] is `true`, the parser will trim the whitespace around
  /// each part when they are captured. [trimParts] must not be `null`.
  ///
  /// {@endtemplate}
  static List<String> split(
    String string, {
    @required List<String> splitters,
    List<Object> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
  }) {
    assert(string != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        delimiters.every(
            (delimiter) => delimiter is String || delimiter is Delimiter));
    assert(removeSplitters != null);
    assert(trimParts != null);

    return StringSplitterConverter(
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
    ).convert(string);
  }

  /// {@template string_splitter.StringSplitter.stream}
  ///
  /// For parsing long strings, [stream] splits [string] into chunks and
  /// streams the returned parts as each chunk is split.
  ///
  /// Splits [string] into parts, slicing the string at each occurrence
  /// of any of the [splitters]. [string] must not be `null`,
  /// [splitters] must not be `null` or empty.
  ///
  /// {@endtemplate}
  ///
  /// {@macro string_splitter.StringSplitter.split.parameters}
  ///
  /// {@template string_splitter.StringSplitter.stream.parameters}
  ///
  /// [chunkSize] represents the number of characters in each chunk, it
  /// must not be `null` and must be `> 0`.
  ///
  /// {@endtemplate}
  static Stream<List<String>> stream(
    String string, {
    @required List<String> splitters,
    List<Object> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
    @required int chunkSize,
  }) {
    assert(string != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        delimiters.every(
            (delimiter) => delimiter is String || delimiter is Delimiter));
    assert(removeSplitters != null);
    assert(trimParts != null);
    assert(chunkSize != null && chunkSize > 0);

    final chunks = chunk(string, chunkSize);
    final input = Stream.fromIterable(chunks);

    return input.transform(
      StringSplitterConverter(
        splitters: splitters,
        delimiters: delimiters,
        removeSplitters: removeSplitters,
        trimParts: trimParts,
        chunkCount: chunks.length,
      ),
    );
  }

  /// {@template string_splitter.StringSplitter.chunk}
  ///
  /// Splits [string] into chunks, [chunkSize] characters in length.
  ///
  /// [string] must not be `null`.
  ///
  /// [chunkSize] must not be `null` and must be `> 0`.
  ///
  /// {@endtemplate}
  static List<String> chunk(String string, int chunkSize) {
    assert(string != null);
    assert(chunkSize != null && chunkSize > 0);

    final chunkCount = (string.length / chunkSize).ceil();

    final chunks = List<String>.generate(chunkCount, (index) {
      final sliceStart = index * chunkSize;
      final sliceEnd = sliceStart + chunkSize;
      return string.substring(
        sliceStart,
        (sliceEnd < string.length) ? sliceEnd : string.length,
      );
    });

    return chunks;
  }
}

extension StringSplitterExtension on String {
  /// {@macro string_splitter.StringSplitter.split}
  ///
  /// {@macro string_splitter.StringSplitter.split.parameters}
  List<String> split({
    @required List<String> splitters,
    List<Object> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
  }) {
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        delimiters.every(
            (delimiter) => delimiter is String || delimiter is Delimiter));
    assert(removeSplitters != null);
    assert(trimParts != null);
    return StringSplitter.split(
      this,
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
    );
  }

  /// {@macro string_splitter.StringSplitter.stream}
  ///
  /// {@macro string_splitter.StringSplitter.split.parameters}
  ///
  /// {@macro string_splitter.StringSplitter.stream.parameters}
  Stream<List<String>> splitStream({
    @required List<String> splitters,
    List<Object> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
    @required int chunkSize,
  }) {
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        delimiters.every(
            (delimiter) => delimiter is String || delimiter is Delimiter));
    assert(removeSplitters != null);
    assert(trimParts != null);
    assert(chunkSize != null && chunkSize > 0);
    return StringSplitter.stream(
      this,
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
      chunkSize: chunkSize,
    );
  }

  /// {@macro string_splitter.StringSplitter.chunk}
  List<String> chunk(int chunkSize) {
    assert(chunkSize != null && chunkSize > 0);
    return StringSplitter.chunk(this, chunkSize);
  }
}
