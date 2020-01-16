import 'dart:convert';
import 'dart:io' show File;
import 'package:meta/meta.dart';
import './string_splitter_converter.dart';

export 'dart:io' show File;

/// A utility class with methods for splitting strings from files.
class StringSplitterIo {
  StringSplitterIo._();

  /// Reads [file] as a string and splits it into parts, slicing the string
  /// at each occurrence of any of the [splitters]. [file] must not
  /// be `null`, [splitters] must not be `null` or empty.
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
  ///
  /// [encoding] is the codec used to read the file.
  static Future<List<String>> split(
    File file, {
    @required List<String> splitters,
    List<dynamic> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
    Encoding encoding = utf8,
  }) async {
    assert(file != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        (delimiters.isNotEmpty &&
            delimiters.every((delimiter) =>
                delimiter is String ||
                (delimiter is List<String> && delimiter.length == 2))));
    assert(removeSplitters != null);
    assert(trimParts != null);

    final string = await file.readAsString(encoding: encoding);

    return StringSplitterConverter(
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
    ).convert(string);
  }

  /// Synchronously reads [file] as a string and splits it into parts,
  /// slicing the string at each occurrence of any of the [splitters].
  /// [file] not be `null`, [splitters] must not be `null` or empty.
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
  ///
  /// [encoding] is the codec used to read the file.
  static List<String> splitSync(
    File file, {
    @required List<String> splitters,
    List<dynamic> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
    Encoding encoding = utf8,
  }) {
    assert(file != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        (delimiters.isNotEmpty &&
            delimiters.every((delimiter) =>
                delimiter is String ||
                (delimiter is List<String> && delimiter.length == 2))));
    assert(removeSplitters != null);
    assert(trimParts != null);

    final string = file.readAsStringSync(encoding: encoding);

    return StringSplitterConverter(
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
    ).convert(string);
  }

  /// For parsing large files, [stream] streams the contents of [file]
  /// and returns the split parts in chunks.
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
  /// [decoder] can be provided to decode [file]s bytes with an alternative
  /// codec. If `null`, it defaults to `utf8.decoder` from the `dart:convert`
  /// library.
  ///
  /// __Note:__ Due to being unable to detect which chunk is the last chunk
  /// from [file], the final part from the last chunk will always be returned
  /// independently in a list containing just the last part. This caveat
  /// shouldn't affect performance in any way.
  static Stream<List<String>> stream(
    File file, {
    @required List<String> splitters,
    List<dynamic> delimiters,
    bool removeSplitters = true,
    bool trimParts = false,
    Converter<List<int>, String> decoder,
  }) {
    assert(file != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters == null ||
        (delimiters.isNotEmpty &&
            delimiters.every((delimiter) =>
                delimiter is String ||
                (delimiter is List<String> && delimiter.length == 2))));
    assert(removeSplitters != null);
    assert(trimParts != null);

    final input = file.openRead();

    return input.transform(decoder ?? utf8.decoder).transform(
          StringSplitterConverter(
            splitters: splitters,
            delimiters: delimiters,
            removeSplitters: removeSplitters,
            trimParts: trimParts,
          ),
        );
  }
}
