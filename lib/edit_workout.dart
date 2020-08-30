import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_lap_dialog.dart';
import './edit_name_dialog.dart';
import './models/workout.dart';
import './store/workout_store.dart';

class EditWorkout extends StatefulWidget {
  final int id;

  const EditWorkout({Key key, @required this.id}) : super(key: key);

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
        workout = context
            .read<WorkoutStore>()
            .workoutList
            .firstWhere((element) => element.id == widget.id,
                orElse: () => null)
            .clone();
      });
    });
  }

  void _createLap() {
    setState(() {
      workout.lapItemList.add(LapItem());
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      var adjustedNextIndex = newIndex;
      if (newIndex > oldIndex) {
        adjustedNextIndex -= 1;
      }
      final item = workout.lapItemList.removeAt(oldIndex);
      workout.lapItemList.insert(adjustedNextIndex, item);
    });
  }

  void _deleteLap(BuildContext context, int lapIndex) async {
    setState(() {
      workout.lapItemList.removeAt(lapIndex);
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

  Future<void> _delete(BuildContext context) async {
    final cancelButton = FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Cancel"),
    );
    final continueButton = FlatButton(
      onPressed: () async {
        await Provider.of<WorkoutStore>(context, listen: false)
            .removeWorkspace(workout.id);
        Navigator.popUntil(context, ModalRoute.withName('/home'));
      },
      child: const Text("Delete"),
    ); // set up the AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text('Are you sure to delete this workout?'),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }

  Future<void> _save(BuildContext context) async {
    try {
      await Provider.of<WorkoutStore>(context, listen: false)
          .updateWorkspace(widget.id, workout.clone());
      Scaffold.of(context).showSnackBar(const SnackBar(
          content: Text('Saved !!', style: TextStyle(fontSize: 24))));
    } catch (_) {
      Scaffold.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Failed to save.',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Colors.red,
      ));
      rethrow;
    }
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
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () => _save(context),
                  );
                },
              ),
            ]),
        body: Center(
          child: ReorderableListView(
              onReorder: _onReorder,
              children: workout.lapItemList
                  .asMap()
                  .entries
                  .map((e) => getLapItemWidget(
                        e.key,
                        e.value,
                        onEdit: () => {_startEditLap(context, e.key)},
                        onDelete: (_) => {_deleteLap(context, e.key)},
                      ))
                  .toList()),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: FloatingActionButton(
                heroTag: 'delete',
                mini: true,
                onPressed: () => _delete(context),
                backgroundColor: Colors.grey,
                tooltip: 'Delete this workout',
                child: const Icon(
                  Icons.delete,
                  size: 16,
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'add',
              onPressed: _createLap,
              tooltip: 'Create a lap',
              child: const Icon(Icons.add),
            ),
          ],
        ));
  }
}

Widget getLapItemWidget(int index, LapItem lapItem,
    {@required void Function() onEdit,
    @required void Function(DismissDirection direction) onDelete}) {
  return Dismissible(
      background: Container(color: Colors.red),
      key: Key(lapItem.key),
      onDismissed: onDelete,
      child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}. ${lapItem.name}',
                          style: const TextStyle(fontSize: 24)),
                      Text('${lapItem.time} s',
                          style: const TextStyle(fontSize: 18)),
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
            )),
            IconButton(
              color: Colors.lightBlue,
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            )
          ])));
}
