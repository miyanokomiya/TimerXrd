import 'package:flutter/material.dart';
import './models/workout.dart';

class EditLapDialog extends StatefulWidget {
  final LapItem lapItem;

  EditLapDialog({Key key, @required this.lapItem}) : super(key: key);

  @override
  State createState() => _EditLapDialogState(this.lapItem);
}

class _EditLapDialogState extends State<EditLapDialog> {
  final LapItem lapItem;
  final nameTextController = TextEditingController();
  final timeTextController = TextEditingController();
  final restTextController = TextEditingController();

  _EditLapDialogState(this.lapItem) : super() {
    nameTextController.text = this.lapItem.name;
    timeTextController.text = this.lapItem.time.toString();
    restTextController.text = this.lapItem.rest.toString();
  }

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<Widget> actions = [
      FlatButton(
        child: Text(localizations.cancelButtonLabel),
        onPressed: () => Navigator.pop(context),
      ),
      FlatButton(
        child: Text(localizations.okButtonLabel),
        onPressed: () {
          String name = nameTextController.text;
          int time = int.tryParse(timeTextController.text);
          int rest = int.tryParse(restTextController.text);
          LapItem lapItem = LapItem();
          lapItem.name = name;
          lapItem.time = time;
          lapItem.rest = rest;
          Navigator.pop<LapItem>(context, lapItem);
        },
      ),
    ];
    final AlertDialog dialog = AlertDialog(
      title: Text("Lap"),
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
          decoration: InputDecoration(
            labelText: 'Time (sec)',
          ),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: restTextController,
          decoration: InputDecoration(
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
