import 'dart:async';
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

enum LapState {
  work,
  rest,
}

class _RunWorkoutPageState extends State<RunWorkoutPage> {
  Workout workout;
  int lapIndex;
  double time;
  Timer timer;
  LapState lapState;

  LapItem get currentLap => workout.lapItemList.length > lapIndex
      ? workout.lapItemList[lapIndex]
      : null;
  LapItem get nextLap => workout.lapItemList.length > lapIndex + 1
      ? workout.lapItemList[lapIndex + 1]
      : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        lapIndex = 0;
        workout =
            context.read<WorkoutStore>().workoutList[widget.index].clone();
        time = currentLap.time.toDouble();
        lapState = LapState.work;
        _play();
      });
    });
  }

  void _onTimer(Timer timer) {
    setState(() {
      time -= 0.1;
      if (time < 0) {
        if (lapState == LapState.work) {
          lapState = LapState.rest;
          time = currentLap.rest.toDouble();
        } else {
          lapIndex++;
          if (currentLap == null) {
            _pause();
            return;
          }

          lapState = LapState.work;
          time = currentLap.time.toDouble();
        }
      }
    });
  }

  void _pause() {
    setState(() {
      timer.cancel();
    });
  }

  void _play() {
    setState(() {
      timer = Timer.periodic(
        const Duration(milliseconds: 100),
        _onTimer,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (workout == null) return Scaffold(body: Container());
    if (currentLap == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(workout.name),
        ),
        body: Center(
            child: Column(children: const [
          Text('Completed !!'),
        ])),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(workout.name),
        ),
        body: Center(
            child: Column(children: [
          Text(currentLap.name),
          Text(lapState == LapState.work ? 'Work' : 'Rest'),
          Text(time.toStringAsFixed(1))
        ])),
        floatingActionButton: timer.isActive
            ? FloatingActionButton(
                onPressed: _pause,
                tooltip: 'Pause',
                child: const Icon(Icons.pause),
              )
            : FloatingActionButton(
                onPressed: _play,
                tooltip: 'Play',
                child: const Icon(Icons.play_arrow),
              ));
  }
}
