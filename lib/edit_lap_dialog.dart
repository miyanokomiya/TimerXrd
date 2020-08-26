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
  final timeTextController = TextEditingController();
  final restTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameTextController.text = widget.lapItem.name;
    timeTextController.text = widget.lapItem.time.toString();
    restTextController.text = widget.lapItem.rest.toString();
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
        onPressed: () {
          final String name = nameTextController.text;
          final int time = int.tryParse(timeTextController.text);
          final int rest = int.tryParse(restTextController.text);
          final LapItem lapItem = LapItem();
          lapItem.name = name;
          lapItem.time = time;
          lapItem.rest = rest;
          Navigator.pop<LapItem>(context, lapItem);
        },
        child: Text(localizations.okButtonLabel),
      ),
    ];
    final AlertDialog dialog = AlertDialog(
      title: const Text("Lap"),
      content: Column(children: [
        TextField(
          controller: nameTextController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
          keyboardType: TextInputType.text,
        ),
        TextField(
          controller: timeTextController,
          decoration: const InputDecoration(
            labelText: 'Time (sec)',
          ),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: restTextController,
          decoration: const InputDecoration(
            labelText: 'Rest (sec)',
          ),
          keyboardType: TextInputType.number,
        ),
      ]),
      actions: actions,
    );

    return dialog;
  }

  @override
  void dispose() {
    timeTextController.dispose();
    super.dispose();
  }
}
