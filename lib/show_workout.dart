import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_workout.dart';
import './models/workout.dart';
import './run_workout.dart';
import './store/workout_store.dart';
import './widgets/lap_item.dart';

class ShowWorkoutPage extends StatelessWidget {
  final int id;

  const ShowWorkoutPage({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workout = context.select((WorkoutStore store) => store.workoutList
        .firstWhere((element) => element.id == id, orElse: () => null));
    final workoutConfig =
        context.select((WorkoutStore store) => store.workoutConfig);

    if (workout == null) {
      return Scaffold(appBar: AppBar(title: const Text('No data')));
    }

    final adjustedIndexList = workout.adjustedIndexList;

    return Scaffold(
      appBar: AppBar(title: Text(workout.displayName), actions: [
        IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditWorkout(id: id)));
            })
      ]),
      body: Center(
        child: ListView(children: [
          Container(
            decoration:
                const BoxDecoration(border: Border(bottom: BorderSide())),
            child: Container(
              color: const Color.fromRGBO(200, 200, 200, 1),
              padding: const EdgeInsets.all(12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        '0. Ready',
                        style: TextStyle(fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${workoutConfig.ready}s',
                        style: const TextStyle(fontSize: 16)),
                  ]),
            ),
          ),
          ...workout.lapItemList
              .asMap()
              .entries
              .map((e) =>
                  getLapItemWidget(context, adjustedIndexList[e.key], e.value))
              .toList()
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RunWorkoutPage(
                      workout: workout, workoutConfig: workoutConfig)));
        },
        tooltip: 'Run',
        backgroundColor: Colors.green,
        child: const Icon(Icons.play_arrow, size: 36),
      ),
    );
  }
}

Widget getLapItemWidget(BuildContext context, int index, LapItem lapItem) {
  return Container(
    decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
    child: Container(
      padding: const EdgeInsets.all(12),
      child: getLapListItem(context, index, lapItem),
    ),
  );
}
