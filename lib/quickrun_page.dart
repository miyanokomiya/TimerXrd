import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './edit_lap_dialog.dart';
import './l10n/l10n.dart';
import './models/workout.dart';
import './run_workout.dart';

class QuickrunPage extends StatefulWidget {
  @override
  _QuickrunPageState createState() => _QuickrunPageState();
}

class _QuickrunPageState extends State<QuickrunPage> {
  int draftTime = 45;
  int draftRest = 15;
  int draftRepeat = 10;
  SharedPreferences prefs;
  bool ready = false;
  final String prefix = 'quick_run';

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs = _prefs;
        draftTime = prefs.getInt('$prefix:time') ?? draftTime;
        draftRest = prefs.getInt('$prefix:rest') ?? draftRest;
        draftRepeat = prefs.getInt('$prefix:repeat') ?? draftRepeat;
      });
    } finally {
      setState(() {
        ready = true;
      });
    }
  }

  void _save(String key, int value) {
    if (prefs != null) {
      prefs.setInt('$prefix:$key', value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ready && prefs == null) return Scaffold(body: Container());

    return Scaffold(
        body: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                child: Text(L10n.of(context).quickRun,
                    style: const TextStyle(fontSize: 36))),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Flexible(
                          child: Text(
                            'Ready',
                            style: TextStyle(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('15s', style: TextStyle(fontSize: 20)),
                      ]),
                  const Divider(),
                  getTimeSelectField(L10n.of(context).time, draftTime,
                      (int next) {
                    setState(() {
                      draftTime = next;
                      _save('time', next);
                    });
                  }),
                  const Divider(),
                  getTimeSelectField(L10n.of(context).rest, draftRest,
                      (int next) {
                    setState(() {
                      draftRest = next;
                      _save('rest', next);
                    });
                  }),
                  const Divider(),
                  getTimeSelectField(L10n.of(context).repeat, draftRepeat,
                      (int next) {
                    setState(() {
                      draftRepeat = next;
                      _save('repeat', next);
                    });
                  }, count: 30, step: 1, unit: ''),
                  const Divider(),
                ],
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RunWorkoutPage(
                        workout: Workout(
                            name: L10n.of(context).quickRun,
                            lapItemList:
                                List.generate(draftRepeat, (index) => index)
                                    .map((index) => LapItem(
                                          name:
                                              '${L10n.of(context).lap} ${index + 1}',
                                          time: draftTime,
                                          rest: draftRest,
                                        ))
                                    .toList()))));
          },
          tooltip: 'Run',
          backgroundColor: Colors.green,
          child: const Icon(Icons.play_arrow, size: 36),
        ));
  }
}
