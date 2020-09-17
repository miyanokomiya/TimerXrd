import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './l10n/l10n.dart';
import './store/workout_store.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<WorkoutStore>(context);

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
                  value: store.hideTimer,
                  onChanged: (bool val) async {
                    await store.updateConfig(hideTimer: val);
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
