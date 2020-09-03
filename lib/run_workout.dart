import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:wakelock/wakelock.dart';
import './models/workout.dart';

AudioCache _player = AudioCache();

class RunWorkoutPage extends StatefulWidget {
  final Workout workout;

  const RunWorkoutPage({Key key, @required this.workout}) : super(key: key);

  @override
  _RunWorkoutPageState createState() => _RunWorkoutPageState();
}

enum LapState {
  ready,
  work,
  rest,
}

class _RunWorkoutPageState extends State<RunWorkoutPage> {
  static const int stepMS = 20;
  static const int readyTime = 5;

  int lapIndex;
  double time;
  Timer timer;
  LapState lapState;
  AudioPlayer _ap;

  Workout get workout => widget.workout;

  List<LapItem> get expandedLapItemList => workout.expandedLapItemList;

  LapItem get currentLap => expandedLapItemList.length > lapIndex
      ? expandedLapItemList[lapIndex]
      : null;

  LapItem get nextLap => expandedLapItemList.length > lapIndex + 1
      ? expandedLapItemList[lapIndex + 1]
      : null;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _restart();
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    timer?.cancel();
    _ap?.dispose();
    _ap = null;
  }

  void _onTimer(Timer timer) {
    setState(() {
      time -= stepMS / 1000;
      // 3.2 looks good timing
      if ((time - 3.2).abs() < 0.01) {
        _ap?.dispose();
        _ap = null;
        _player.play('sounds/countdown.mp3').then((value) => _ap = value);
      } else if (time < 0) {
        switch (lapState) {
          case LapState.ready:
            lapState = LapState.work;
            time = currentLap.time.toDouble();
            break;
          case LapState.work:
            lapState = LapState.rest;
            time = currentLap.rest.toDouble();
            break;
          default:
            lapIndex++;
            if (currentLap == null) {
              timer.cancel();
              Future.delayed(const Duration(seconds: 3)).then((_) {
                _ap?.dispose();
                _ap = null;
              });
              return;
            }
            lapState = LapState.work;
            time = currentLap.time.toDouble();
            break;
        }
      }
    });
  }

  void _pause() {
    setState(() {
      _ap?.dispose();
      _ap = null;
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
      time = readyTime.toDouble();
      lapState = LapState.ready;
      _play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentLap == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(workout.displayName),
          ),
          body: Center(
              child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Text('💪 Good Job 👍', style: TextStyle(fontSize: 36)),
            ),
            Expanded(
                child: Container(
              decoration:
                  const BoxDecoration(border: Border(top: BorderSide())),
              child: ListView(
                  children: expandedLapItemList
                      .asMap()
                      .entries
                      .map((e) => getLapItemWidget(e.key, e.value))
                      .toList()
                        ..add(Container(height: 80))),
            ))
          ])),
          floatingActionButton: FloatingActionButton(
            onPressed: _restart,
            tooltip: 'Restart',
            backgroundColor: Colors.green,
            child: const Icon(Icons.repeat),
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(workout.displayName),
        ),
        body: Center(
            child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  getCurrentActText(),
                  style: const TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: getCountDownWidget(
                    lapState, _getLapTime(lapState, currentLap), time),
              ),
              getNextActWidget(),
            ])),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 4, left: 12, bottom: 20),
            child: const Text('Sound by OtoLogic(https://otologic.jp)',
                style: TextStyle(fontSize: 16)),
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
                backgroundColor: Colors.green,
                child: const Icon(Icons.play_arrow, size: 36),
              ));
  }

  String getCurrentActText() {
    if (lapState == LapState.ready) {
      return 'Ready';
    } else if (lapState == LapState.work) {
      return currentLap.name;
    } else {
      return 'Rest';
    }
  }

  Widget getNextActWidget() {
    return Column(
      children: [
        const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Icon(
              Icons.arrow_downward,
              color: Colors.blue,
              size: 36,
            )),
        Padding(
          padding: const EdgeInsets.all(4),
          child: getNextActLabel(),
        ),
      ],
    );
  }

  Widget getNextActLabel() {
    if (lapState == LapState.ready) {
      return Text(
        '${currentLap.displayName} (${currentLap.time}s)',
        style: const TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      );
    } else if (lapState == LapState.work) {
      return Text(
        'Rest (${currentLap.rest}s)',
        style: const TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      );
    } else if (nextLap != null) {
      return Text(
        '${nextLap.displayName} (${nextLap.time}s)',
        style: const TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Finish',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.done_all, color: Colors.green, size: 30),
          ),
        ],
      );
    }
  }
}

Widget getCountDownWidget(LapState state, int range, double current) {
  return CustomPaint(
      painter: CirclePainter(
          radian: (current / range) * 2 * pi, color: _getLapStateColor(state)),
      child: Container(
          height: 320,
          child: Center(
              child: Text(
            current.ceil().toStringAsFixed(0),
            style: const TextStyle(fontSize: 60),
          ))));
}

class CirclePainter extends CustomPainter {
  final double radian;
  final Color color;

  CirclePainter({@required this.radian, this.color = Colors.green}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-pi / 2);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawArc(
        Rect.fromCenter(center: center, height: radius * 2, width: radius * 2),
        0,
        2 * pi,
        true,
        Paint()..color = const Color.fromARGB(255, 220, 220, 220));
    canvas.drawArc(
        Rect.fromCenter(center: center, height: radius * 2, width: radius * 2),
        0,
        radian,
        true,
        Paint()..color = color);

    canvas.drawCircle(center, radius * 0.7, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

int _getLapTime(LapState lapState, LapItem lapItem) {
  switch (lapState) {
    case LapState.ready:
      return _RunWorkoutPageState.readyTime;
    case LapState.work:
      return lapItem.time;
    default:
      return lapItem.rest;
  }
}

Color _getLapStateColor(LapState lapState) {
  switch (lapState) {
    case LapState.ready:
      return Colors.yellow;
    case LapState.work:
      return Colors.green;
    default:
      return Colors.blue;
  }
}

Widget getLapItemWidget(int index, LapItem lapItem) {
  return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.check, color: Colors.green, size: 30),
          ),
          Expanded(
            child: Text(
              '${index + 1}. ${lapItem.displayName}',
              style: const TextStyle(fontSize: 20),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${lapItem.time} s', style: const TextStyle(fontSize: 18)),
        ]),
      ));
}
