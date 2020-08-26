class Workout {
  String name = 'Workout';
  List<LapItem> lapItemList = [];

  Workout();

  Workout clone() {
    final ret = Workout();
    ret.name = name;
    ret.lapItemList = lapItemList.map((l) => l.clone()).toList();
    return ret;
  }
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

  LapItem({this.name, this.time, this.rest});

  LapItem clone() {
    final ret = LapItem();
    ret.name = name;
    ret.time = time;
    ret.rest = rest;
    return ret;
  }
}
