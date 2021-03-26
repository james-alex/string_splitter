## [0.2.0] - March 25, 2021

* Added the [Delimiter] class; the [delimiters] parameters now acccept lists
of [String]s and [Delimiter]s, instead of [String]s and `List<String>`s.

* The `string_splitter` library now extends [String] with the [split],
[splitStream], and [chunk] methods.

* The `string_splitter_io` library now extends [File] with the [split],
[splitSync], and [splitStream] methods.

## [0.1.0+2] - January 16, 2020

* Documentation and formatting changes.

* Bug fix in the file parsing test caused by Windows replacing linebreaks with
a backwards compatible line ending. Documentation was updated to inform users of
how to address the issue if needed.

## [0.1.0+1] - September 8, 2019

* Bug fix.

## [0.1.0] - September 8, 2019

* Initial release.
