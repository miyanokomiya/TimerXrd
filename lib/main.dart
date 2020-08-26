import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_workout.dart';
import './models/workout.dart';
import './store/workout_store.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => WorkoutStore(),
        child: MaterialApp(
          title: 'Timer Xrd',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutList =
        context.select((WorkoutStore store) => store.workoutList);
    return Scaffold(
      body: Center(
          child: ListView(
        children: workoutList
            .asMap()
            .entries
            .map((e) => getWorkoutWidget(context, e.key, e.value))
            .toList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: Provider.of<WorkoutStore>(context).addWorkspace,
        tooltip: 'Create Workout',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget getWorkoutWidget(BuildContext context, int index, Workout workout) {
  return Row(children: [
    Expanded(
      child: Column(children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(12),
            child: Text(workout.name, style: const TextStyle(fontSize: 24)))
      ]),
    ),
    IconButton(
      padding: const EdgeInsets.all(20.0),
      color: Colors.lightBlue,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditWorkout(index: index, workout: workout)));
      },
      icon: const Icon(Icons.edit),
    )
  ]);
}
