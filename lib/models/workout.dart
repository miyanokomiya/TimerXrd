class Workout {
  String name = 'Workout';
  List<LapItem> lapItemList = [];

  Workout();

  Workout clone() {
    final ret = Workout();
    ret.name = this.name;
    ret.lapItemList = this.lapItemList.map((l) => l.clone()).toList();
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

  LapItem();

  LapItem clone() {
    final ret = LapItem();
    ret.name = this.name;
    ret.time = this.time;
    ret.rest = this.rest;
    return ret;
  }
}
