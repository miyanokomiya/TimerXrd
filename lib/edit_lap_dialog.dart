import 'package:algolia/algolia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import './l10n/l10n.dart';
import './models/workout.dart';

final algolia = Algolia.init(
    applicationId: DotEnv().env['ALGOLIA_APPLICATION_ID'],
    apiKey: DotEnv().env['ALGOLIA_API_KEY']);

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
  bool draftIsLeftAndRight;

  // Algolia algolia = Application.algolia;

  @override
  void initState() {
    super.initState();
    nameTextController.text = widget.lapItem.name;
    draftTime = widget.lapItem.time;
    draftRest = widget.lapItem.rest;
    draftIsLeftAndRight = widget.lapItem.isLeftAndRight;
  }

  Future<List<String>> _suggestionsCallback(String pattern) async {
    if (nameTextController.text == '') {
      return [];
    }

    AlgoliaQuery query = algolia.instance.index('exercises');
    query = query.search(nameTextController.text);

    try {
      final _results = (await query.getObjects()).hits;
      return _results.map((e) => e.data['name_jp']).cast<String>().toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
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
                isLeftAndRight: draftIsLeftAndRight,
              ));
        },
        child: Text(localizations.okButtonLabel),
      ),
    ];

    return AlertDialog(
      title: Text(L10n.of(context).editLap),
      content: SingleChildScrollView(
          child: Column(children: [
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: Colors.blue,
          child: Image.asset(
              'assets/images/search-by-algolia-dark-background.png',
              height: 20),
        ),
        TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: nameTextController,
            decoration: InputDecoration(
              labelText: L10n.of(context).name,
            ),
          ),
          hideOnEmpty: true,
          hideOnLoading: true,
          suggestionsCallback: _suggestionsCallback,
          itemBuilder: (context, String suggestion) {
            return ListTile(
              dense: true,
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (String value) {
            nameTextController.text = value;
          },
        ),
        const Divider(),
        getTimeSelectField(L10n.of(context).time, draftTime, (int next) {
          setState(() {
            draftTime = next;
          });
        }),
        const Divider(),
        getTimeSelectField(L10n.of(context).rest, draftRest, (int next) {
          setState(() {
            draftRest = next;
          });
        }),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(L10n.of(context).leftAndRight),
            Checkbox(
              value: draftIsLeftAndRight,
              onChanged: (bool val) {
                setState(() {
                  draftIsLeftAndRight = val;
                });
              },
            )
          ],
        )
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

Widget getTimeSelectField(
    String label, int value, void Function(int val) onChanged,
    {int step = 5, int count = 15, String unit = 's'}) {
  final secondOptions = List.generate(count, (i) => (i + 1) * step);

  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(fontSize: 20)),
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
          child: Text('$value$unit'),
        );
      }).toList(),
    )
  ]);
}
