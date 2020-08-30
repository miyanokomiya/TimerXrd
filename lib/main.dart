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
    return FutureBuilder(
        future: Provider.of<WorkoutStore>(context, listen: false).loadValue(),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Timer Xrd'),
              ),
              body: const Center(
                  child:
                      Text('Failed to load.', style: TextStyle(fontSize: 36))),
            );
          }

          final workoutList =
              ctx.select((WorkoutStore store) => store.workoutList);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Timer Xrd'),
            ),
            body: Center(
                child: ListView(
                    children: workoutList
                        .asMap()
                        .entries
                        .map((e) => getWorkoutWidget(ctx, e.key, e.value))
                        .toList())),
            floatingActionButton: FloatingActionButton(
              onPressed: Provider.of<WorkoutStore>(context).addWorkspace,
              tooltip: 'Create Workout',
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}

Widget getWorkoutWidget(BuildContext context, int index, Workout workout) {
  return Card(
      child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowWorkoutPage(index: index)));
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(workout.name, style: const TextStyle(fontSize: 24)),
                    Text(workout.totalTimeText,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ))));
}
