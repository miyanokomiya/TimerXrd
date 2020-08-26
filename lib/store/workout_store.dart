import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutStore with ChangeNotifier {
  List<Workout> workoutList = [
    Workout(
      name: 'New Workout',
      lapItemList: [
        LapItem(name: 'New Lap'),
        LapItem(name: 'New Lap'),
      ],
    )
  ];

  void addWorkspace() {
    workoutList.add(Workout(
      name: 'New Workout',
      lapItemList: [
        LapItem(name: 'New Lap'),
        LapItem(name: 'New Lap'),
      ],
    ));
    notifyListeners();
  }

  void updateWorkspace(int index, Workout next) {
    workoutList[index] = next;
    notifyListeners();
  }
}
