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

  List<LapItem> get expandedLapItemList {
    final List<LapItem> list = [];
    for (final lap in lapItemList) {
      list.addAll(lap.expandLapItemList());
    }
    return list;
  }

  int get totalTime => expandedLapItemList
      .map((e) => e.time + e.rest)
      .reduce((value, element) => value + element);

  List<int> get adjustedIndexList {
    var i = 0;
    return lapItemList.map((e) {
      final current = i;
      i += 1;
      if (e.isLeftAndRight) {
        i += 1;
      }
      return current;
    }).toList();
  }

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
  bool isLeftAndRight;

  LapItem({
    this.name = '',
    this.time = 45,
    this.rest = 15,
    this.isLeftAndRight = false,
  }) {
    key = uuid.v4();
  }

  LapItem.fromMap(Map map) {
    name = map['name'] as String;
    time = map['time'] as int;
    rest = map['rest'] as int;
    isLeftAndRight = map['is_left_and_right'] == 1;
    key = uuid.v4();
  }

  String get displayName => name == '' ? 'no name' : name;

  LapItem clone() {
    return LapItem(
        name: name, time: time, rest: rest, isLeftAndRight: isLeftAndRight);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
      'rest': rest,
      'is_left_and_right': isLeftAndRight ? 1 : 0,
    };
  }

  List<LapItem> expandLapItemList() {
    final List<LapItem> list = [];
    if (isLeftAndRight) {
      list.add(clone()..name += ' L');
      list.add(clone()..name += ' R');
    } else {
      list.add(clone());
    }
    return list;
  }
}
