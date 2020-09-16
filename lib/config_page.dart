import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './l10n/l10n.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final String prefix = 'config';
  SharedPreferences prefs;
  bool hideTimer = false;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs = _prefs;
        hideTimer = prefs.getBool('$prefix:hideTimer') ?? hideTimer;
      });
    } finally {
      setState(() {
        ready = true;
      });
    }
  }

  void _saveBool(String key, bool value) {
    if (prefs != null) {
      prefs.setBool('$prefix:$key', value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ready && prefs == null) return Scaffold(body: Container());

    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(
                    L10n.of(context).configHideTimer,
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Checkbox(
                  value: hideTimer,
                  onChanged: (bool val) {
                    _saveBool('hideTimer', val);
                    setState(() {
                      hideTimer = val;
                    });
                  },
                )
              ]),
            ],
          ),
        )
      ],
    ));
  }
}
