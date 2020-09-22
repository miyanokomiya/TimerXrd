import 'package:test/test.dart';
import 'package:TimerXrd/store/workout_store.dart';
import 'package:TimerXrd/models/workout.dart';

void main() {
  group('saveDoneLog, getDoneLogs', () {
    test('save & get done logs', () async {
      final workout =
          Workout(name: 'abc', lapItemList: [LapItem(name: 'lap 1')]);
      await saveDoneLog(workout);
      final now = DateTime.now();
      final list = await getDoneLogs(
          DateTime(now.year, now.month - 1, now.day).toUtc(),
          DateTime(now.year, now.month, now.day + 1).toUtc());
      expect(list.length, 1);
      expect(list[0].workoutName, 'ab');
    });
  });
}
