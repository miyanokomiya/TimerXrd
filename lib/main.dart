import 'package:flutter/material.dart';
import './edit_workout.dart';
import './models/workout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer Xrd',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Workout> workoutList = [];

  void _createWorkout() {
    setState(() {
      workoutList.add(Workout());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView(
        children: workoutList.map((w) => getWorkoutWidget(context, w)).toList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _createWorkout,
        tooltip: 'Create Workout',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget getWorkoutWidget(BuildContext context, Workout workout) {
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
                builder: (context) => EditWorkout(workout: workout)));
      },
      icon: const Icon(Icons.edit),
    )
  ]);
}
