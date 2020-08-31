import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_workout.dart';
import './models/workout.dart';
import './run_workout.dart';
import './store/workout_store.dart';

class ShowWorkoutPage extends StatefulWidget {
  final int id;

  const ShowWorkoutPage({Key key, @required this.id}) : super(key: key);

  @override
  _ShowWorkoutPageState createState() => _ShowWorkoutPageState();
}

class _ShowWorkoutPageState extends State<ShowWorkoutPage> {
  @override
  Widget build(BuildContext context) {
    final workout = context.select((WorkoutStore store) => store.workoutList
        .firstWhere((element) => element.id == widget.id, orElse: () => null));

    if (workout == null) {
      return Scaffold(appBar: AppBar(title: const Text('No data')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(workout.displayName), actions: [
        IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditWorkout(id: widget.id)));
            })
      ]),
      body: Center(
        child: ListView(
            children: workout.lapItemList
                .asMap()
                .entries
                .map((e) => getLapItemWidget(e.key, e.value))
                .toList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RunWorkoutPage(id: widget.id)));
        },
        tooltip: 'Run',
        backgroundColor: Colors.green,
        child: const Icon(Icons.play_arrow, size: 36),
      ),
    );
  }
}

Widget getLapItemWidget(int index, LapItem lapItem) {
  return Container(
    decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Text('${index + 1}. ${lapItem.displayName}',
                style: const TextStyle(fontSize: 24)),
          ),
          Text('${lapItem.time} s', style: const TextStyle(fontSize: 18)),
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
            Text('${lapItem.rest} s', style: const TextStyle(fontSize: 18)),
          ],
        )
      ]),
    ),
  );
}
