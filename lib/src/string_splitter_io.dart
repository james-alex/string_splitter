import 'dart:convert';
import 'dart:io' show File;
import 'package:meta/meta.dart';
import './string_splitter_converter.dart';

export 'dart:io' show File;

/// A utility class with methods for splitting strings from files.
class StringSplitterIo {
  StringSplitterIo._();

  /// {@template string_splitter_io.StringSplitterIo.split}
  ///
  /// Reads [file] as a string and splits it into parts, slicing the string
  /// at each occurrence of any of the [splitters]. [file] must not
  /// be `null`, [splitters] must not be `null` or empty.
  ///
  /// {@endtemplate}
  ///
  /// {@macro string_splitter.StringSplitter.split.parameters}
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

  /// {@template string_splitter_io.StringSplitterIo.splitSync}
  ///
  /// Synchronously reads [file] as a string and splits it into parts,
  /// slicing the string at each occurrence of any of the [splitters].
  /// [file] not be `null`, [splitters] must not be `null` or empty.
  ///
  /// {@endtemplate}
  ///
  /// {@macro string_splitter.StringSplitter.split.parameters}
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

  /// {@template string_splitter_io.StringSplitterIo.stream}
  ///
  /// For parsing large files, [stream] streams the contents of [file]
  /// and returns the split parts in chunks.
  ///
  /// {@endtemplate}
  ///
  /// {@macro string_splitter.StringSplitter.stream.parameters}
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
