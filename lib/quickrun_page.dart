import 'package:flutter/material.dart';
import './edit_lap_dialog.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                child: const Text('Quick Run', style: TextStyle(fontSize: 36))),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  getTimeSelectField('Time', draftTime, (int next) {
                    setState(() {
                      draftTime = next;
                    });
                  }),
                  const Divider(),
                  getTimeSelectField('Rest', draftRest, (int next) {
                    setState(() {
                      draftRest = next;
                    });
                  }),
                  const Divider(),
                  getTimeSelectField('Repeat', draftRepeat, (int next) {
                    setState(() {
                      draftRepeat = next;
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
                            name: 'Quick run',
                            lapItemList:
                                List.generate(draftRepeat, (index) => index)
                                    .map((index) => LapItem(
                                          name: 'Lap ${index + 1}',
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
