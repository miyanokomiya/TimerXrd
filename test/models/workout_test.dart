import 'package:flutter_test/flutter_test.dart';
import 'package:TimerXrd/models/workout.dart';

void main() {
  group('Workout', () {
    group('expandedLapItemList', () {
      test('isLeftAndRight: true', () {
        final workout = Workout(lapItemList: [
          LapItem(name: '0'),
          LapItem(name: '1', isLeftAndRight: true),
        ]);
        final ret = workout.expandedLapItemList;
        expect(ret.length, 3);
        expect(ret[0].name, '0');
        expect(ret[1].name, '1 L');
        expect(ret[2].name, '1 R');
      });
    });
  });

  group('LapItem', () {
    group('expandLapItemList', () {
      test('isLeftAndRight: false', () {
        final ret = LapItem(name: 'abc').expandLapItemList;
        expect(ret.length, 1);
        expect(ret[0].name, 'abc');
      });
      test('isLeftAndRight: true', () {
        final ret =
            LapItem(name: 'abc', isLeftAndRight: true).expandLapItemList;
        expect(ret.length, 2);
        expect(ret[0].name, 'abc L');
        expect(ret[1].name, 'abc R');
      });
    });
  });
}
