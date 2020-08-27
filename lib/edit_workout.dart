import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_lap_dialog.dart';
import './edit_name_dialog.dart';
import './models/workout.dart';
import './store/workout_store.dart';

class EditWorkout extends StatefulWidget {
  final int index;

  const EditWorkout({Key key, @required this.index}) : super(key: key);

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends State<EditWorkout> {
  Workout workout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        workout = context.read<WorkoutStore>().workoutList[widget.index].clone();
      });
    });
  }

  void _createLap() {
    setState(() {
      workout.lapItemList.add(LapItem());
    });
  }

  Future<void> _startEditLap(BuildContext context, int lapIndex) async {
    final input = await showTimerDialog(context, lapIndex);
    if (input == null) return;

    setState(() {
      workout.lapItemList[lapIndex] = input;
    });
  }

  Future<void> _startEditName(BuildContext context) async {
    final Widget dialog = EditNameDialog(name: workout.name);
    final String next = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
    if (next == null) return;

    setState(() {
      workout.name = next;
    });
  }

  void _save(BuildContext context) {
    Provider.of<WorkoutStore>(context, listen: false)
        .updateWorkspace(widget.index, workout.clone());

    const snackBar =
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
    if (workout == null) return Scaffold(body: Container());

    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              _startEditName(context);
            },
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white))),
              child: Text(workout.name),
            ),
          ),
          actions: [
            Builder(
              builder: (BuildContext context) {
                return RaisedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE'),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget getLapItemWidget(int index, LapItem lapItem, void Function() onEdit) {
  return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Text('${index + 1}. ${lapItem.name}',
                      style: const TextStyle(fontSize: 24)),
                ),
                Text('${lapItem.time} s', style: const TextStyle(fontSize: 18)),
              ]),
              const Divider(
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: const Text('Rest', style: TextStyle(fontSize: 18)),
                  ),
                  Text('${lapItem.rest} s',
                      style: const TextStyle(fontSize: 18)),
                ],
              )
            ]),
          ),
        ),
        IconButton(
          color: Colors.lightBlue,
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
        )
      ]));
}
