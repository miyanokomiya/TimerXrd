import 'package:flutter/material.dart';
import './models/workout.dart';

class EditWorkout extends StatefulWidget {
  final Workout workout;

  EditWorkout({Key key, @required this.workout}) : super(key: key);

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends State<EditWorkout> {
  void _createLap() {
    setState(() {
      widget.workout.lapItemList.add(LapItem());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.workout.lapItemList
                .map((lapItem) => getLapItemWidget(lapItem))
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

Widget getLapItemWidget(LapItem lapItem) {
  return Column(children: [
    Text(lapItem.name),
    Text(lapItem.time.toString()),
    Text(lapItem.rest.toString()),
  ]);
}
