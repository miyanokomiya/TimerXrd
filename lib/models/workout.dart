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
