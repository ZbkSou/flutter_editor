import 'dart:math' as math;

///
///  diff
///  @author: flutter_editor
///  @description:
///  Created by zhao on2021/7/2 .


// Diff between two texts - old text and new text
class Diff {
  Diff(this.start, this.deleted, this.inserted);

  // Start index in old text at which changes begin.
  final int start;

  /// The deleted text
  final String deleted;

  // The inserted text
  final String inserted;

  @override
  String toString() {
    return 'Diff[$start, "$deleted", "$inserted"]';
  }
}


/* Get diff operation between old text and new text */
Diff getDiff(String oldText, String newText, int cursorPosition) {
  var end = oldText.length;
  final delta = newText.length - end;
  for (final limit = math.max(0, cursorPosition - delta);
  end > limit && oldText[end - 1] == newText[end + delta - 1];
  end--) {}
  var start = 0;
  for (final startLimit = cursorPosition - math.max(0, delta);
  start < startLimit && oldText[start] == newText[start];
  start++) {}
  final deleted = (start >= end) ? '' : oldText.substring(start, end);
  final inserted = newText.substring(start, end + delta);
  return Diff(start, deleted, inserted);
}