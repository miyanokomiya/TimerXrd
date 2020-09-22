import 'package:flutter/material.dart';
import './config_page.dart';
import './done_log_list_page.dart';
import './l10n/l10n.dart';
import './quickrun_page.dart';
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
    DoneLogListPage(),
    ConfigPage(),
  ];

  void _onItemTapped(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.playlist_add), title: Text(l10n.workouts)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.timer), title: Text(l10n.quickRun)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.done_all), title: Text(l10n.logs)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings), title: Text(l10n.configTitle)),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
