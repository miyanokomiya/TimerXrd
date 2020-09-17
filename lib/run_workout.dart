import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import './l10n/l10n.dart';
import './models/workout.dart';
import './store/workout_store.dart';

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
  static const int readyTime = 15;

  int lapIndex = 0;
  double time = 0;
  Timer timer;
  LapState lapState = LapState.ready;
  AudioPlayer _ap;
  bool hideTimer = false;

  Workout get workout => widget.workout;

  List<LapItem> get expandedLapItemList => workout?.expandedLapItemList ?? [];

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
    _player.load('sounds/countdown.mp3').then((_) {
      _restart();
    });
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        hideTimer = prefs.getBool('config:hideTimer') ?? hideTimer;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    timer?.cancel();
    _ap?.dispose();
    _ap = null;
  }

  Future<void> _playSound() async {
    if (_ap != null) {
      await _ap.seek(const Duration());
      await _ap.resume();
    } else {
      _ap = await _player.play('sounds/countdown.mp3');
    }
  }

  void _onTimer(Timer timer) {
    setState(() {
      time -= stepMS / 1000;
      // 3.2 looks good timing
      if ((time - 3.2).abs() < 0.01) {
        _playSound();
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
      _ap?.pause();
      timer.cancel();
    });
  }

  void _play() {
    setState(() {
      _ap?.resume();
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
      return getGoodJobWidget(context);
    }

    final store = Provider.of<WorkoutStore>(context);
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
                  getCurrentActText(context),
                  style: const TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: getCountDownWidget(
                    lapState, _getLapTime(lapState, currentLap), time,
                    hideTimer: store.hideTimer),
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
        floatingActionButton: timer?.isActive ?? false
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

  Scaffold getGoodJobWidget(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(workout.displayName),
        ),
        body: Center(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text('💪 ${L10n.of(context).goodJob} 👍',
                style: const TextStyle(fontSize: 36)),
          ),
          Expanded(
              child: Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide())),
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
          onPressed: () {
            Share.share(getSharedText(workout));
          },
          tooltip: 'Share',
          backgroundColor: Colors.green,
          child: const Icon(Icons.share),
        ));
  }

  String getCurrentActText(BuildContext context) {
    if (lapState == LapState.ready) {
      return L10n.of(context).ready;
    } else if (lapState == LapState.work) {
      return currentLap.name;
    } else {
      return L10n.of(context).rest;
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
          child: getNextActLabel(context),
        ),
      ],
    );
  }

  Widget getNextActLabel(BuildContext context) {
    if (lapState == LapState.ready) {
      return Text(
        '${currentLap.displayName} (${currentLap.time}s)',
        style: const TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      );
    } else if (lapState == LapState.work) {
      return Text(
        '${L10n.of(context).rest} (${currentLap.rest}s)',
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
        children: [
          Text(
            L10n.of(context).finish,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.done_all, color: Colors.green, size: 30),
          ),
        ],
      );
    }
  }
}

Widget getCountDownWidget(LapState state, int range, double current,
    {bool hideTimer = false}) {
  final _hideTimer = hideTimer && state == LapState.work;
  return CustomPaint(
      painter: CirclePainter(
          radian: (_hideTimer ? 1.0 : current / range) * 2 * pi,
          color: _getLapStateColor(state)),
      child: Container(
          height: 320,
          child: Center(
              child: Text(
            _hideTimer ? '$range' : current.ceil().toStringAsFixed(0),
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

String getSharedText(Workout workout) {
  final adjustedIndexList = workout.adjustedIndexList;
  return '💪 Done 👍\n${workout.lapItemList.asMap().entries.map((element) {
    final number = adjustedIndexList[element.key] + 1;
    if (element.value.isLeftAndRight) {
      return '$number-${number + 1}. ${element.value.displayName}(LR) ${element.value.time}s';
    }
    return '$number. ${element.value.displayName} ${element.value.time}s';
  }).join('\n')}';
}
