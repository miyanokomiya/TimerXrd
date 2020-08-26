class Workout {
  String name;
  List<LapItem> lapItemList;

  Workout({this.name = 'Workout', this.lapItemList = const []});

  Workout clone() {
    final ret = Workout();
    ret.name = name;
    ret.lapItemList = lapItemList.map((l) => l.clone()).toList();
    return ret;
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

  LapItem clone() {
    final ret = LapItem();
    ret.name = name;
    ret.time = time;
    ret.rest = rest;
    return ret;
  }
}
