import 'package:test/test.dart';
import 'package:TimerXrd/store/workout_store.dart';
import 'package:TimerXrd/models/workout.dart';

void main() {
  tearDown(() {
    deleteDB();
  });

  group('saveDoneLog, getDoneLogs', () {
    test('save & get done logs', () async {
      final workout =
      Workout(name: 'abc', lapItemList: [LapItem(name: 'lap 1')]);
      final src = await saveDoneLog(workout);
      expect(src.id, 1);
      expect(src.doneLogItems.length, 1);
      expect(src.doneLogItems[0].lapName, 'lap 1');
      final now = DateTime.now();
      final list = await getDoneLogs(
          DateTime(now.year, now.month - 1, now.day).toUtc(),
          DateTime(now.year, now.month, now.day + 1).toUtc());
      expect(list.length, 1);
      expect(list[0].workoutName, 'abc');
    });
    test('where from <= created_at < to sort by created_at desc', () async {
      final workout1 = Workout(name: '4/9');
      final workout2 = Workout(name: '4/10');
      final workout3 = Workout(name: '5/10');
      final workout4 = Workout(name: '5/11');
      await saveDoneLog(workout1, createdAt: DateTime(2020, 4, 9).toUtc());
      await saveDoneLog(workout2, createdAt: DateTime(2020, 4, 10).toUtc());
      await saveDoneLog(workout3, createdAt: DateTime(2020, 5, 10).toUtc());
      await saveDoneLog(workout4, createdAt: DateTime(2020, 5, 11).toUtc());
      final list = await getDoneLogs(
          DateTime(2020, 4, 10).toUtc(), DateTime(2020, 5, 11).toUtc());
      expect(list.length, 2);
      expect(list[0].workoutName, '5/10');
      expect(list[1].workoutName, '4/10');
    });
  });

  group('getDoneLog', () {
    test('get done log detail', () async {
      final workout =
      Workout(name: 'abc',
          lapItemList: [LapItem(name: 'lap 1', time: 2, isLeftAndRight: true), LapItem(name: 'lap 2')]);
      final src = await saveDoneLog(workout);
      final log = await getDoneLog(src.id);
      expect(log.workoutName, 'abc');
      expect(log.doneLogItems.length, 3);
      expect(log.doneLogItems[0].lapName, 'lap 1 L');
      expect(log.doneLogItems[0].lapTime, 2);
      expect(log.doneLogItems[1].lapName, 'lap 1 R');
      expect(log.doneLogItems[2].lapName, 'lap 2');
    });
  });
}
