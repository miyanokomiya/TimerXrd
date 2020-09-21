import 'package:flutter_test/flutter_test.dart';
import 'package:TimerXrd/utils/datetime.dart';

void main() {
  group('totalTimeText', () {
    test('without hours', () {
      expect(formatSeconds(1 * 60 + 2), '01:02');
      expect(formatSeconds(21 * 60 + 59), '21:59');
    });
    test('with hours', () {
      expect(formatSeconds(1 * 60 * 60 + 1 * 60 + 2), '1:01:02');
      expect(formatSeconds(1 * 60 * 60 + 21 * 60 + 59), '1:21:59');
    });
  });

  group('formatDateTime', () {
    test('format MM/dd hh:mm', () {
      expect(formatDateTime(DateTime(2000, 1, 2, 3, 4)), '01/02 03:04');
      expect(formatDateTime(DateTime(2000, 10, 12, 21, 34)), '10/12 21:34');
    });
  });

  group('formatDate', () {
    test('format MM/dd', () {
      expect(formatDate(DateTime(2000, 1, 2)), '01/02');
      expect(formatDate(DateTime(2000, 10, 12)), '10/12');
    });
  });
}
