import 'package:flutter/material.dart';
import './models/workout.dart';
import './edit_lap_dialog.dart';

class EditWorkout extends StatefulWidget {
  final Workout workout;

  EditWorkout({Key key, @required this.workout}) : super(key: key);

  @override
  _EditWorkoutState createState() => _EditWorkoutState(this.workout.clone());
}

class _EditWorkoutState extends State<EditWorkout> {
  Workout workout;

  _EditWorkoutState(this.workout) : super();

  void _createLap() {
    setState(() {
      this.workout.lapItemList.add(LapItem());
    });
  }

  void _startEditLap(BuildContext context, int lapIndex) async {
    LapItem input = await showTimerDialog(context, lapIndex);
    if (input == null) return;

    setState(() {
      workout.lapItemList[lapIndex] = input;
    });
  }

  void _save(BuildContext context) {
    final snackBar =
        SnackBar(content: Text('Saved !!', style: TextStyle(fontSize: 24)));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<LapItem> showTimerDialog(BuildContext context, int lapIndex) {
    final Widget dialog = EditLapDialog(lapItem: workout.lapItemList[lapIndex]);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.name), actions: [
        Builder(
          builder: (BuildContext context) {
            return RaisedButton.icon(
              icon: Icon(Icons.save),
              label: Text('SAVE'),
              color: Colors.transparent,
              textColor: Colors.white,
              onPressed: () => _save(context),
            );
          },
        ),
      ]),
      body: Center(
        child: ListView(
            children: workout.lapItemList
                .asMap()
                .entries
                .map((e) => getLapItemWidget(
                    e.key, e.value, () => {_startEditLap(context, e.key)}))
                .toList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createLap,
        tooltip: 'Create Workout',
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget getLapItemWidget(int index, LapItem lapItem, Function onEdit) {
  return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Text((index + 1).toString() + '. ' + lapItem.name,
                      style: TextStyle(fontSize: 24)),
                ),
                Text(lapItem.time.toString() + 's',
                    style: TextStyle(fontSize: 18)),
              ]),
              Divider(
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 12),
                    child: Text('Rest', style: TextStyle(fontSize: 18)),
                  ),
                  Text(lapItem.rest.toString() + 's',
                      style: TextStyle(fontSize: 18)),
                ],
              )
            ]),
          ),
        ),
        IconButton(
          color: Colors.lightBlue,
          onPressed: onEdit,
          icon: Icon(Icons.edit),
        )
      ]));
}
