import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/workout.dart';

const String configPrefix = 'config';

class WorkoutStore with ChangeNotifier {
  SharedPreferences prefs;
  List<Workout> workoutList = [];
  WorkoutConfig workoutConfig = WorkoutConfig();

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

    prefs = await SharedPreferences.getInstance();
    workoutConfig.hideTimer =
        prefs.getBool('$configPrefix:hideTimer') ?? workoutConfig.hideTimer;
    workoutConfig.ready =
        prefs.getInt('$configPrefix:ready') ?? workoutConfig.ready;
  }

  Future<void> removeWorkspace(int id) async {
    final db = await getDataBase();
    await db.transaction((txn) async {
      await txn.delete('Workout', where: 'id = ?', whereArgs: [id]);
    });

    workoutList = workoutList.where((element) => element.id != id).toList();
    notifyListeners();
  }

  Future<Workout> addWorkspace() async {
    final workout = Workout(
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
    return workout;
  }

  Future<void> updateWorkspace(int id, Workout workout) async {
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
    final itemIndex = workoutList.indexWhere((element) => element.id == id);
    workoutList[itemIndex] = workout;
    notifyListeners();
  }

  Future<void> updateConfig({bool hideTimer, int ready}) async {
    if (prefs != null) {
      await prefs.setBool(
          '$configPrefix:hideTimer', hideTimer ?? workoutConfig.hideTimer);
      await prefs.setInt('$configPrefix:ready', ready ?? workoutConfig.ready);
      workoutConfig.hideTimer = hideTimer ?? workoutConfig.hideTimer;
      workoutConfig.ready = ready ?? workoutConfig.ready;
      notifyListeners();
    }
  }
}

Database _database;

Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  for (var i = oldVersion + 1; i <= newVersion; i++) {
    final queries = scripts[i.toString()];
    for (final query in queries) {
      await db.execute(query);
    }
  }
}

Future<Database> getDataBase() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'app.db');
  // await deleteDatabase(path);

  const version = 2;

  if (_database != null) return _database;

  final database = await openDatabase(
    join(path),
    version: version,
    onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE workout(
          id INTEGER PRIMARY KEY,
          name TEXT
        );
        """);
      await db.execute("""
        CREATE TABLE lap_item(
          workout_id INTEGER,
          item_index INTEGER,
          name TEXT,
          time INTEGER,
          rest INTEGER,
          PRIMARY KEY(workout_id, item_index),
          FOREIGN KEY (workout_id) REFERENCES workout(id) ON UPDATE CASCADE ON DELETE CASCADE
        );
        """);
      onUpgrade(db, 1, version);
    },
    onUpgrade: onUpgrade,
  );
  database.execute('PRAGMA foreign_keys=ON;');
  return database;
}

const Map<String, List<String>> scripts = {
  '2': [
    """
    ALTER TABLE lap_item ADD COLUMN is_left_and_right INTEGER DEFAULT 0;
    """,
  ],
};
