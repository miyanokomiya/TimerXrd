import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_lap_dialog.dart';
import './edit_name_dialog.dart';
import './l10n/l10n.dart';
import './models/workout.dart';
import './store/workout_store.dart';
import './widgets/lap_item.dart';

class EditWorkout extends StatefulWidget {
  final int id;

  const EditWorkout({Key key, @required this.id}) : super(key: key);

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends State<EditWorkout> {
  Workout workout;
  final _controller = ScrollController();

  Workout get workoutOrigin => context
      .read<WorkoutStore>()
      .workoutList
      .firstWhere((element) => element.id == widget.id, orElse: () => null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        workout = workoutOrigin.clone();
      });
    });
  }

  bool get _isChanged => !workout.isEqual(workoutOrigin);

  Future<bool> _onWillPop() async {
    if (!_isChanged) {
      return true;
    }

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(L10n.of(context).confirmDiscardChanges),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No', style: TextStyle(color: Colors.black)),
              ),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _createLap() {
    setState(() {
      workout.lapItemList.add(LapItem());
      Future.delayed(const Duration(milliseconds: 50))
          .then((_) => _controller.animateTo(
                _controller.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
              ));
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

  void _cloneLap(int lapIndex) {
    setState(() {
      workout.lapItemList
          .insert(lapIndex, workout.lapItemList[lapIndex].clone());
    });
  }

  void _deleteLap(int lapIndex) {
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
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.black),
      ),
    );
    final continueButton = FlatButton(
      color: Colors.red,
      textColor: Colors.white,
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
          content: Text(L10n.of(context).confirmDiscardChanges),
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
          content: Text('Saved!!', style: TextStyle(fontSize: 24))));
      // update '_isChanged'
      setState(() {});
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

    final adjustedIndexList = workout.adjustedIndexList;

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: AppBar(
                title: GestureDetector(
                  onTap: () {
                    _startEditName(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.white))),
                    child: Text(
                      workout.displayName,
                    ),
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
                        onPressed: _isChanged ? () => _save(context) : null,
                        disabledColor: Colors.grey,
                      );
                    },
                  ),
                ]),
            body: Center(
              child: ReorderableListView(
                  scrollController: _controller,
                  onReorder: _onReorder,
                  children: workout.lapItemList
                      .asMap()
                      .entries
                      .map((e) => getLapItemWidget(
                            adjustedIndexList[e.key],
                            e.value,
                            onEdit: () => {_startEditLap(context, e.key)},
                            onClone: () => {_cloneLap(e.key)},
                            onDelete: (_) => {_deleteLap(e.key)},
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
            )));
  }
}

Widget getLapItemWidget(int index, LapItem lapItem,
    {@required void Function() onEdit,
    @required void Function() onClone,
    @required void Function(DismissDirection direction) onDelete}) {
  return Dismissible(
      background: Container(color: Colors.red),
      key: Key(lapItem.key),
      onDismissed: onDelete,
      child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
                child: Container(
              padding: const EdgeInsets.all(12),
              child: getLapListItem(index, lapItem),
            )),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  color: Colors.lightBlue,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  color: Colors.lightBlue,
                  onPressed: onClone,
                  icon: const Icon(Icons.content_copy),
                ),
              ],
            )
          ])));
}
