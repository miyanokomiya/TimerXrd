import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './edit_workout.dart';
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
          routes: <String, WidgetBuilder>{
            '/': (_) => MyHomePage(),
          },
        ));
  }
}

class MyHomePage extends StatelessWidget {
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

          final store = Provider.of<WorkoutStore>(context);
          final workoutList = store.workoutList;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Timer Xrd'),
            ),
            body: Center(
                child: ListView(
                    children: workoutList
                        .asMap()
                        .entries
                        .map((e) => getWorkoutWidget(ctx, e.value))
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
        });
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
                    Text(workout.name, style: const TextStyle(fontSize: 24)),
                    Text(workout.totalTimeText,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ))));
}
