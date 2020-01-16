/// Returns the code units for each string in [splitters].
List<List<int>> splitters(List<String> splitters) {
  assert(splitters != null);

  return splitters.map((splitter) => splitter.codeUnits).toList();
}

/// Returns the code units for each string in [delimiters].
List<dynamic> delimiters(List<dynamic> delimiters) {
  if (delimiters == null) return null;

  assert(delimiters.isNotEmpty &&
      delimiters.every((delimiter) =>
          delimiter is String ||
          (delimiter is List<String> && delimiter.length == 2)));

  return delimiters.map((delimiter) {
    if (delimiter is List<String>) {
      final codeUnits = List<List<int>>(2);

      codeUnits[0] = delimiter[0].codeUnits;
      codeUnits[1] = delimiter[1].codeUnits;

      return codeUnits;
    }

    return delimiter.codeUnits;
  }).toList();
}

/// Compares [pattern] to [string] and returns `true` if
/// their values match, otherwise returns `false`.
bool match(List<int> pattern, List<int> string) {
  assert(pattern != null && pattern.isNotEmpty);
  assert(string != null && string.length == pattern.length);

  var match = true;

  for (var i = 0; i < pattern.length; i++) {
    if (pattern[i] != string[i]) {
      match = false;
      break;
    }
  }

  return match;
}
