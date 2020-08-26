import 'package:flutter/material.dart';
import './models/workout.dart';

class EditLapDialog extends StatefulWidget {
  final LapItem lapItem;

  const EditLapDialog({Key key, @required this.lapItem}) : super(key: key);

  @override
  State createState() => _EditLapDialogState();
}

class _EditLapDialogState extends State<EditLapDialog> {
  final nameTextController = TextEditingController();
  int draftTime;
  int draftRest;

  @override
  void initState() {
    super.initState();
    nameTextController.text = widget.lapItem.name;
    draftTime = widget.lapItem.time;
    draftRest = widget.lapItem.rest;
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> actions = [
      FlatButton(
        onPressed: () => Navigator.pop(context),
        child: Text(localizations.cancelButtonLabel),
      ),
      FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: () {
          Navigator.pop<LapItem>(
              context,
              LapItem(
                name: nameTextController.text,
                time: draftTime,
                rest: draftRest,
              ));
        },
        child: Text(localizations.okButtonLabel),
      ),
    ];

    return AlertDialog(
      title: const Text("Edit Lap"),
      content: Form(
          child: Column(children: [
        TextField(
          controller: nameTextController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
          keyboardType: TextInputType.text,
        ),
        const Divider(),
        getTimeSelectField('Time', draftTime, (int next) {
          setState(() {
            draftTime = next;
          });
        }),
        const Divider(),
        getTimeSelectField('Rest', draftRest, (int next) {
          setState(() {
            draftRest = next;
          });
        }),
        const Divider(),
      ])),
      actions: actions,
    );
  }

  @override
  void dispose() {
    nameTextController.dispose();
    super.dispose();
  }
}

final secondOptions = List.generate(15, (i) => (i + 1) * 5);

Widget getTimeSelectField(
    String label, int value, void Function(int val) onChanged) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label),
    DropdownButton<int>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 30,
      elevation: 16,
      style: const TextStyle(fontSize: 20, color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      onChanged: onChanged,
      items: secondOptions.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('${value}s'),
        );
      }).toList(),
    )
  ]);
}
