import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/workout.dart';
import './store/workout_store.dart';

class RunWorkoutPage extends StatefulWidget {
  final int index;

  const RunWorkoutPage({Key key, @required this.index}) : super(key: key);

  @override
  _RunWorkoutPageState createState() => _RunWorkoutPageState();
}

class _RunWorkoutPageState extends State<RunWorkoutPage> {
  bool isPause = false;

  void _pause() {
    setState(() {
      isPause = true;
    });
  }

  void _play() {
    setState(() {
      isPause = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Workout workout =
        context.select((WorkoutStore store) => store.workoutList[widget.index]);

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: const Center(child: Text('TODO')),
      floatingActionButton: isPause
          ? FloatingActionButton(
              onPressed: _play,
              tooltip: 'Play',
              child: const Icon(Icons.play_arrow),
            )
          : FloatingActionButton(
              onPressed: _pause,
              tooltip: 'Pause',
              child: const Icon(Icons.pause),
            ),
    );
  }
}
