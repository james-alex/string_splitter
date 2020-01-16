import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import './helpers/code_units.dart' as code_units;

/// A [Converter] for splitting strings and returning the parts in a list.
class StringSplitterConverter extends Converter<String, List<String>> {
  /// A [Converter] for splitting strings and returning the parts in a list.
  const StringSplitterConverter({
    @required this.splitters,
    @required this.delimiters,
    @required this.removeSplitters,
    @required this.trimParts,
    this.chunkCount,
  })  : assert(splitters != null),
        assert(delimiters != null),
        assert(removeSplitters != null),
        assert(trimParts != null),
        assert(chunkCount == null || chunkCount > 0);

  /// The [String]s used to split the string, the string will be sliced
  /// at each occurrence of a splitter.
  final List<String> splitters;

  /// To exclude splitters from slicing a string, [delimiters] can be provided.
  /// [delimiters] can be provided as a [String], in which case, that
  /// [String] will be used as both the opening and closing delimiter.
  /// Or, as a [List<String>] with 2 children, the first child being the
  /// opening delimiter, and the second child being the closing delimiter.
  /// [delimiters] must not be empty if it is provided.
  final List<dynamic> delimiters;

  /// If [removeSplitters] is `true`, each string part will be captured
  /// without the splitting character(s), if `false`, the splitter will
  /// be included with the part. [removeSplitters] must not be `null`.
  final bool removeSplitters;

  /// If [trimParts] is `true`, the parser will trim the whitespace around
  /// each part when they are captured. [trimParts] must not be `null`.
  final bool trimParts;

  /// The number of chunks being parsed.
  final int chunkCount;

  @override
  List<String> convert(String string) {
    assert(string != null);

    return _StringSplitter.split(
      string,
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
      carryOver: false,
    ).parts;
  }

  @override
  Stream<List<String>> bind(Stream<String> stream) {
    return Stream<List<String>>.eventTransformed(
      stream,
      (sink) => _StringSplitterEventSink(
        eventSink: sink,
        splitters: splitters,
        delimiters: delimiters,
        removeSplitters: removeSplitters,
        trimParts: trimParts,
        chunkCount: chunkCount,
      ),
    );
  }
}

class _StringSplitterEventSink extends _StringSplitterSink
    implements EventSink<String> {
  _StringSplitterEventSink({
    @required EventSink<List<String>> eventSink,
    @required List<String> splitters,
    @required List<dynamic> delimiters,
    @required bool removeSplitters,
    @required bool trimParts,
    int chunkCount,
  })  : _eventSink = eventSink,
        super(
          sink: eventSink,
          splitters: splitters,
          delimiters: delimiters,
          removeSplitters: removeSplitters,
          trimParts: trimParts,
          chunkCount: chunkCount,
        );

  final EventSink<List<String>> _eventSink;

  @override
  void addError(Object o, [StackTrace stackTrace]) {
    _eventSink.addError(o, stackTrace);
  }
}

class _StringSplitterSink extends ChunkedConversionSink<String> {
  _StringSplitterSink({
    @required this.sink,
    @required this.splitters,
    @required this.delimiters,
    @required this.removeSplitters,
    @required this.trimParts,
    this.chunkCount,
  })  : assert(splitters != null),
        assert(delimiters != null),
        assert(removeSplitters != null),
        assert(trimParts != null),
        assert(chunkCount == null || chunkCount > 0);

  final Sink<List<String>> sink;

  final List<String> splitters;

  final List<dynamic> delimiters;

  final bool removeSplitters;

  final bool trimParts;

  final int chunkCount;

  String _carryOver;

  int _chunkCount = 1;

  @override
  void add(String chunk) {
    // Add any text remaining from the last chunk
    // to the beginning of this chunk.
    if (_carryOver != null) {
      chunk = _carryOver + chunk;
      _carryOver = null;
    }

    final isNotLast = chunkCount == null || _chunkCount < chunkCount;

    // Split this chunk.
    final stringParts = _StringSplitter.split(
      chunk,
      splitters: splitters,
      delimiters: delimiters,
      removeSplitters: removeSplitters,
      trimParts: trimParts,
      carryOver: (isNotLast) ? true : false,
    );

    // Add the split chunk to the sink.
    sink.add(stringParts.parts);

    // Carry over the text remaining from this chunk,
    // if it's not the last chunk.
    if (isNotLast) {
      _carryOver = stringParts.carryOver;
      _chunkCount++;
    } else {
      _carryOver = null;
      _chunkCount = 1;
    }
  }

  @override
  void close() {
    if (_carryOver != null) {
      if (trimParts) _carryOver = _carryOver.trim();
      sink.add([_carryOver]);
      _carryOver = null;
    }

    sink.close();
  }
}

/// A helper class containing the method that handles the actual string parsing,
/// and stores the returned string parts and the text remaining from the end of
/// the parsed strings, if parsing in chunks.
class _StringSplitter {
  const _StringSplitter(this.parts, this.carryOver) : assert(parts != null);

  /// The split string parts.
  final List<String> parts;

  /// The text remaining in a chunk after splitting.
  final String carryOver;

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
  /// If [carryOver] is `true`, text remaining at the end of [string] will
  /// be stored to be handled seperately from the split parts, if `false`,
  /// any remaining text will be appended to the parts.
  static _StringSplitter split(
    String string, {
    List<String> splitters,
    List<dynamic> delimiters,
    bool removeSplitters,
    bool trimParts,
    bool carryOver,
  }) {
    assert(string != null);
    assert(splitters != null && splitters.isNotEmpty);
    assert(delimiters != null);
    assert(removeSplitters != null);
    assert(trimParts != null);
    assert(carryOver != null);

    final stringParts = <String>[];

    final splitterCodeUnits = code_units.splitters(splitters);
    final delimiterCodeUnits = code_units.delimiters(delimiters);

    var delimited = false;

    var sliceStart = 0;

    for (var i = 0; i < string.length; i++) {
      // Check for delimiters.
      if (delimiters != null) {
        for (List<dynamic> delimiters in delimiterCodeUnits) {
          final List<int> delimiter = delimiters.first is List
              ? delimited ? delimiters.last : delimiters.first
              : delimiters;

          final sliceEnd = i + delimiter.length;

          if (sliceEnd < string.length &&
              code_units.match(
                delimiter,
                string.substring(i, sliceEnd).codeUnits,
              )) {
            delimited = !delimited;
            i += delimiter.length - 1;
            break;
          }
        }
      }

      // Don't check delimited text for splitters.
      if (delimited) continue;

      // Check for splitters.
      for (var splitter in splitterCodeUnits) {
        var sliceEnd = i + splitter.length;

        // If a splitter was found, capture the current slice.
        if (sliceEnd < string.length &&
            code_units.match(
              splitter,
              string.substring(i, sliceEnd).codeUnits,
            )) {
          if (removeSplitters) sliceEnd = i;
          var stringPart = string.substring(sliceStart, sliceEnd);
          if (trimParts) stringPart = stringPart.trim();
          stringParts.add(stringPart);

          sliceStart = removeSplitters ? i + splitter.length : sliceEnd;
          i = sliceStart - 1;

          break;
        }
      }
    }

    // Capture the remaining text
    var remainder =
        (sliceStart < string.length) ? string.substring(sliceStart) : null;

    // If the remaining text shouldn't be carried over, add it as a part.
    if (!carryOver && remainder != null) {
      if (trimParts) remainder = remainder.trim();
      stringParts.add(remainder);
      remainder = null;
    }

    return _StringSplitter(stringParts, remainder);
  }
}
