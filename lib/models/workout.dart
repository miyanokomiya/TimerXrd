import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

class Workout {
  int id;
  String name;
  List<LapItem> lapItemList;

  Workout({this.name = '', this.lapItemList = const [], this.id});

  Workout.fromMap(Map map) {
    id = map['id'] as int;
    name = map['name'] as String;
  }

  String get displayName => name == '' ? 'no name' : name;

  int get totalTime => lapItemList
      .map((e) => e.time + e.rest)
      .reduce((value, element) => value + element);

  String get totalTimeText {
    final time = totalTime;
    final m = (time / 60).floor();
    final s = time % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
  // tmp unique key
  String key;

  String name;
  int time;
  int rest;

  LapItem({
    this.name = '',
    this.time = 45,
    this.rest = 15,
  }) {
    key = uuid.v4();
  }

  LapItem.fromMap(Map map) {
    name = map['name'] as String;
    time = map['time'] as int;
    rest = map['rest'] as int;
    key = uuid.v4();
  }

  String get displayName => name == '' ? 'no name' : name;

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

const Map<String, List<String>> scripts = {
  // '2': [
  //   'ALTER TABLE lap_item ADD COLUMN lap_type INTEGER DEFAULT 0;',
  // ],
};

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

  const version = 1;

  if (_database != null) return _database;
  
  final database = 
      await openDatabase(
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
