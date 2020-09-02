import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_workout.dart';
import './models/workout.dart';
import './show_workout.dart';
import './store/workout_store.dart';

class WorkoutListPage extends StatelessWidget {
  Future<void> _addWorkspace(WorkoutStore store, BuildContext context) async {
    Workout workout;
    try {
      workout = await store.addWorkspace();
    } catch (_) {
      Scaffold.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Failed to create.',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Colors.red,
      ));
      rethrow;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowWorkoutPage(id: workout.id)));
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditWorkout(id: workout.id)));
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<WorkoutStore>(context);
    final workoutList = store.workoutList;

    return Scaffold(
      body: Center(
          child: ListView(
              children: workoutList
                  .asMap()
                  .entries
                  .map((e) => getWorkoutWidget(context, e.value))
                  .toList())),
      floatingActionButton: Builder(builder: (BuildContext ctx) {
        return FloatingActionButton(
          onPressed: () {
            _addWorkspace(store, ctx);
          },
          tooltip: 'Create Workout',
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}

Widget getWorkoutWidget(BuildContext context, Workout workout) {
  return Card(
      child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowWorkoutPage(id: workout.id)));
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        workout.displayName,
                        style: const TextStyle(fontSize: 24),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(workout.totalTimeText,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ))));
}
