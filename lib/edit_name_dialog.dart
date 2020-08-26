import 'package:flutter/material.dart';

class EditNameDialog extends StatefulWidget {
  final String name;

  const EditNameDialog({Key key, @required this.name}) : super(key: key);

  @override
  State createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  final nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameTextController.text = widget.name;
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
          Navigator.pop<String>(
            context,
            nameTextController.text,
          );
        },
        child: Text(localizations.okButtonLabel),
      ),
    ];

    return AlertDialog(
      title: const Text("Edit Name"),
      content: Form(
          child: Column(children: [
        TextField(
          autofocus: true,
          controller: nameTextController,
          keyboardType: TextInputType.text,
        ),
        const Divider(),
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
