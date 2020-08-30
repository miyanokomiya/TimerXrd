import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Workout {
  int id;
  String name;
  List<LapItem> lapItemList;

  Workout({this.name = 'Workout', this.lapItemList = const [], this.id});

  Workout.fromMap(Map map) {
    id = map['id'] as int;
    name = map['name'] as String;
  }

  Workout clone() {
    return Workout(
        id: id,
        name: name,
        lapItemList: lapItemList.map((l) => l.clone()).toList());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class LapGroup {
  int repetition;
  List<LapItem> lapItemList;

  LapGroup({this.repetition = 1, this.lapItemList = const []});
}

class LapItem {
  String name;
  int time;
  int rest;

  LapItem({this.name = 'Lap', this.time = 45, this.rest = 15});

  LapItem.fromMap(Map map) {
    name = map['name'] as String;
    time = map['time'] as int;
    rest = map['rest'] as int;
  }

  LapItem clone() {
    return LapItem(name: name, time: time, rest: rest);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
      'rest': rest,
    };
  }
}

Database _database;

Future<Database> getDataBase() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'app.db');
  // await deleteDatabase(path);

  final database = _database ??
      await openDatabase(
        join(path),
        version: 1,
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
          PRIMARY KEY(workout_id, item_index)
        );
        """);
        },
      );
  return database;
}
