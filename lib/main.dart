import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/workout.dart';
import './show_workout.dart';
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
  return Card(
    child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShowWorkoutPage(index: index)));
        },
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(12),
            child: Text(workout.name, style: const TextStyle(fontSize: 24)))),
  );
}
