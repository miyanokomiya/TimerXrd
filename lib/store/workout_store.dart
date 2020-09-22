import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/done_log.dart';
import '../models/workout.dart';

const String configPrefix = 'config';

class WorkoutStore with ChangeNotifier {
  SharedPreferences prefs;
  List<Workout> workoutList = [];
  WorkoutConfig workoutConfig = WorkoutConfig();

  Future<void> loadValue() async {
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

Future<DoneLog> saveDoneLog(Workout workout, {DateTime createdAt}) async {
  final db = await getDataBase();
  final doneLog = DoneLog.fromWorkout(workout, createdAt: createdAt);
  await db.transaction((txn) async {
    final id = await txn.insert(
        'done_log', DoneLog.fromWorkout(workout, createdAt: createdAt).toMap());
    doneLog.id = id;
    final batch = txn.batch();
    for (int i = 0; i < workout.lapItemList.length; i++) {
      final e = workout.lapItemList[i];
      batch.insert('done_log_item', {
        'done_log_id': id,
        'lap_name': e.name,
        'lap_time': e.time,
        'item_index': i,
      });
    }
    await batch.commit();
  });
  return doneLog
    ..doneLogItems = workout.lapItemList
        .map((e) => DoneLogItem.fromLapItem(doneLog.id, e))
        .toList();
}

Future<List<DoneLog>> getDoneLogs(DateTime from, DateTime to) async {
  final db = await getDataBase();
  final List<Map> maps = await db.rawQuery('''
    SELECT * FROM done_log WHERE ? <= created_at AND created_at < ? ORDER BY created_at DESC
    ''', [from.toIso8601String(), to.toIso8601String()]);
  return List.generate(maps.length, (i) => DoneLog.fromMap(maps[i]));
}

Future<DoneLog> getDoneLog(int doneLogId) async {
  final db = await getDataBase();
  final List<Map> maps = await db.query('done_log',
      where: 'id = ?', whereArgs: [doneLogId], limit: 1);
  if (maps.length != 1) {
    throw Exception('Not found done_log: $doneLogId');
  }
  final doneLog = DoneLog.fromMap(maps[0]);
  final List<Map> itemMaps = await db.query('done_log_item',
      where: 'done_log_id = ?',
      whereArgs: [doneLogId],
      orderBy: 'item_index ASC');
  return doneLog
    ..doneLogItems = itemMaps.map((e) => DoneLogItem.fromMap(e)).toList();
}

Database _database;
const filename = 'app.db';
const version = 4;

Future<void> deleteDB() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, filename);
  await deleteDatabase(path);
  if (_database != null) {
    await _database.close();
    _database = null;
  }
}

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
  final path = join(databasesPath, filename);

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
      await onUpgrade(db, 1, version);
    },
    onUpgrade: onUpgrade,
  );
  await database.execute('PRAGMA foreign_keys=ON;');
  return database;
}

const Map<String, List<String>> scripts = {
  '2': [
    """
    ALTER TABLE lap_item ADD COLUMN is_left_and_right INTEGER DEFAULT 0;
    """,
  ],
  '3': [
    """
    CREATE TABLE done_log(
      id INTEGER PRIMARY KEY,
      workout_name TEXT NOT NULL,
      workout_total_time INTEGER NOT NULL,
      created_at DATETIME NOT NULL
    );
    """,
    """
    CREATE INDEX done_log_workout_name ON done_log(workout_name);
    """,
    """
    CREATE INDEX done_log_created_at ON done_log(created_at);
    """,
    """
    CREATE TABLE done_log_item(
      done_log_id INTEGER,
      lap_name TEXT NOT NULL,
      lap_time INTEGER NOT NULL,
      FOREIGN KEY (done_log_id) REFERENCES done_log(id) ON UPDATE CASCADE ON DELETE CASCADE
    );
    """,
    """
    CREATE INDEX done_log_item_done_log_id ON done_log_item(done_log_id);
    """,
    """
    CREATE INDEX done_log_item_lap_name ON done_log_item(lap_name);
    """,
  ],
  '4': [
    """
    ALTER TABLE done_log_item ADD COLUMN item_index INTEGER DEFAULT 0;
    """,
  ],
};
