class Workout {
  String name = 'Workout';
  List<LapItem> lapItemList = [];

  Workout();
}

class LapGroup {
  int repetition = 1;
  List<LapItem> lapItemList = [];

  LapGroup();
}

class LapItem {
  String name = 'Lap';
  int time = 45;
  int rest = 15;

  LapItem();
}

