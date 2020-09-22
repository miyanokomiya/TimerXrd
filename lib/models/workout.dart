import 'package:uuid/uuid.dart';
import '../utils/datetime.dart';

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
      list.addAll(lap.expandLapItemList);
    }
    return list;
  }

  int get totalTime => expandedLapItemList.isEmpty
      ? 0
      : expandedLapItemList
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

  String get totalTimeText => formatSeconds(totalTime);

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

  bool isEqual(Workout b) {
    if (name != b.name) return false;
    if (lapItemList.length != b.lapItemList.length) return false;
    for (var i = 0; i < lapItemList.length; i++) {
      if (!lapItemList[i].isEqual(b.lapItemList[i])) return false;
    }
    return true;
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

  bool isEqual(LapItem b) {
    if (name != b.name) return false;
    if (time != b.time) return false;
    if (rest != b.rest) return false;
    if (isLeftAndRight != b.isLeftAndRight) return false;
    return true;
  }

  List<LapItem> get expandLapItemList {
    final List<LapItem> list = [];
    if (isLeftAndRight) {
      list.add(clone()
        ..isLeftAndRight = false
        ..name += ' L');
      list.add(clone()
        ..isLeftAndRight = false
        ..name += ' R');
    } else {
      list.add(clone());
    }
    return list;
  }
}

class WorkoutConfig {
  bool hideTimer;
  int ready;

  WorkoutConfig({this.hideTimer = false, this.ready = 15});
}
