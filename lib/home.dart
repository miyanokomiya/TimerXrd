import 'package:flutter/material.dart';
import './quickrun_page.dart';
import './l10n/l10n.dart';
import './workout_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _pageWidgets = [
    WorkoutListPage(),
    QuickrunPage(),
  ];

  void _onItemTapped(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Xrd'),
      ),
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.playlist_add),
              title: Text(L10n.of(context).workouts)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.timer),
              title: Text(L10n.of(context).quickRun)),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
