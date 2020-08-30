import 'dart:async';
import 'dart:math';
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
  static const int stepMS = 20;
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
        workout =
            context.read<WorkoutStore>().workoutList[widget.index].clone();
        _restart();
      });
    });
  }

  void _onTimer(Timer timer) {
    setState(() {
      time -= stepMS / 1000;
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
        const Duration(milliseconds: stepMS),
        _onTimer,
      );
    });
  }

  void _restart() {
    setState(() {
      lapIndex = 0;
      time = currentLap.time.toDouble();
      lapState = LapState.work;
      _play();
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
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text('Good Job!!!', style: TextStyle(fontSize: 36)),
            ),
          ])),
          floatingActionButton: FloatingActionButton(
            onPressed: _restart,
            tooltip: 'Restart',
            backgroundColor: Colors.red,
            child: const Icon(Icons.repeat),
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(workout.name),
        ),
        body: Center(
            child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text(currentLap.name, style: const TextStyle(fontSize: 36)),
          ),
          Text(lapState == LapState.work ? 'Work' : 'Rest',
              style: const TextStyle(fontSize: 24)),
          getCountDownWidget(
              lapState,
              lapState == LapState.work ? currentLap.time : currentLap.rest,
              time),
          Column(
            children: nextLap == null
                ? []
                : [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Next: ${nextLap.name}',
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ],
          )
        ])),
        floatingActionButton: timer.isActive
            ? FloatingActionButton(
                onPressed: _pause,
                tooltip: 'Pause',
                backgroundColor: Colors.grey,
                child: const Icon(Icons.pause),
              )
            : FloatingActionButton(
                onPressed: _play,
                tooltip: 'Play',
                backgroundColor: Colors.red,
                child: const Icon(Icons.play_arrow, size: 36),
              ));
  }
}

Widget getCountDownWidget(LapState state, int range, double current) {
  return CustomPaint(
      painter: CirclePainter(
          radian: (current / range) * 2 * pi,
          color: state == LapState.work ? Colors.green : Colors.blue),
      child: Container(
          height: 200,
          child: Center(
              child: Text(
            current.toStringAsFixed(1),
            style: const TextStyle(fontSize: 24),
          ))));
}

class CirclePainter extends CustomPainter {
  final double radian;
  final Color color;

  CirclePainter({@required this.radian, this.color = Colors.green}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 150.0;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
        Rect.fromCenter(center: center, height: radius, width: radius),
        0,
        radian,
        true,
        Paint()..color = color);

    canvas.drawCircle(center, radius - 100.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
