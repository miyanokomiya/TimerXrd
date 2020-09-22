import 'package:flutter/foundation.dart';

import './workout.dart';

class DoneLog {
  int id;
  String workoutName;
  int workoutTotalTime;
  List<DoneLogItem> doneLogItems = [];

  // must be UTC
  DateTime createdAt;

  DoneLog(
      {@required this.workoutName,
      @required this.workoutTotalTime,
      @required this.createdAt});

  DoneLog.fromWorkout(Workout workout, {DateTime createdAt}) {
    workoutName = workout.name;
    workoutTotalTime = workout.totalTime;
    this.createdAt = createdAt ?? DateTime.now().toUtc();
  }

  DoneLog.fromMap(Map map) {
    id = map['id'] as int;
    workoutName = map['workout_name'] as String;
    workoutTotalTime = map['workout_total_time'] as int;
    createdAt = DateTime.parse(map['created_at'] as String);
  }

  DateTime get localCreatedAt => createdAt.toLocal();

  String get displayName => workoutName == '' ? 'no name' : workoutName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_name': workoutName,
      'workout_total_time': workoutTotalTime,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DoneLogItem {
  String lapName;
  int lapTime;

  DoneLogItem.fromMap(Map map) {
    lapName = map['lap_name'] as String;
    lapTime = map['lap_time'] as int;
  }

  DoneLogItem.fromLapItem(LapItem lapItem) {
    lapName = lapItem.name;
    lapTime = lapItem.time;
  }

  String get displayName => lapName == '' ? 'no name' : lapName;

  Map<String, dynamic> toMap() {
    return {
      'lap_name': lapName,
      'lap_time': lapTime,
    };
  }
}
