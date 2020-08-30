import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutStore with ChangeNotifier {
  List<Workout> workoutList = [];

  Future<void> loadValue() async {
    debugPrint('loadValue');
    final db = await getDataBase();
    final List<Map> maps = await db.rawQuery('SELECT * FROM workout');
    final List<Map> lapItemMaps =
        await db.rawQuery('SELECT * FROM lap_item ORDER BY item_index ASC');

    workoutList = List.generate(maps.length, (i) {
      final id = maps[i]['id'] as int;
      return Workout(
          id: id,
          name: maps[i]['name'] as String,
          lapItemList: lapItemMaps
              .where((element) => element['workout_id'] == id)
              .map((e) => LapItem.fromMap(e))
              .toList());
    });

    // notifyListeners();
  }

  Future<void> addWorkspace() async {
    final workout = Workout(
      name: 'New Workout',
      lapItemList: [
        LapItem(),
        LapItem(),
      ],
    );

    final db = await getDataBase();
    await db.transaction((txn) async {
      final workoutId = await txn.insert('Workout', workout.toMap());
      workout.lapItemList.asMap().entries.forEach((e) async {
        final map = e.value.toMap();
        map['workout_id'] = workoutId;
        map['item_index'] = e.key;
        await txn.insert('lap_item', map);
      });
      workout.id = workoutId;
    });

    workoutList.add(workout);
    notifyListeners();
  }

  Future<void> updateWorkspace(int itemIndex, Workout workout) async {
    final db = await getDataBase();
    await db.transaction((txn) async {
      await txn.update('Workout', workout.toMap(),
          where: 'id = ?', whereArgs: [workout.id]);
      await txn
          .delete('lap_item', where: 'workout_id = ?', whereArgs: [workout.id]);
      final batch = txn.batch();
      workout.lapItemList.asMap().entries.forEach((e) async {
        final map = e.value.toMap();
        map['workout_id'] = workout.id;
        map['item_index'] = e.key;
        batch.insert('lap_item', map);
      });
      await batch.commit();
    });
    workoutList[itemIndex] = workout;
    notifyListeners();
  }
}
