import 'package:TimerXrd/models/done_log.dart';
import 'package:flutter/material.dart';
import './l10n/l10n.dart';
import './store/workout_store.dart';
import './utils/datetime.dart';

class DoneLogDetailPage extends StatelessWidget {
  final int id;

  const DoneLogDetailPage({Key key, @required this.id}) : super(key: key);

  Future<void> _delete(BuildContext context) async {
    final cancelButton = FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        MaterialLocalizations.of(context).cancelButtonLabel,
        style: const TextStyle(color: Colors.black),
      ),
    );
    final continueButton = FlatButton(
      color: Colors.red,
      textColor: Colors.white,
      onPressed: () async {
        await deleteDoneLog(id);
        Navigator.pop(context);
        Navigator.pop(context, true);
      },
      child: Text(L10n.of(context).delete),
    ); // set up the AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(L10n.of(context).confirmDeleteLog),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDoneLog(id),
      builder: (BuildContext context, AsyncSnapshot<DoneLog> snapshot) {
        if (snapshot.hasData) {
          final doneLog = snapshot.data;
          return Scaffold(
              appBar: AppBar(title: Text(doneLog.workoutName)),
              body: Center(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(formatDateTime(doneLog.createdAt),
                          style: const TextStyle(fontSize: 20)),
                      Container(width: 20),
                      Text(formatSeconds(doneLog.workoutTotalTime),
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                Expanded(
                    child: ListView(
                        children:
                            doneLog.doneLogItems.map(getWorkLogItem).toList()))
              ])),
              floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: FloatingActionButton(
                        heroTag: 'delete',
                        mini: true,
                        onPressed: () => _delete(context),
                        backgroundColor: Colors.grey,
                        tooltip: 'Delete this log',
                        child: const Icon(
                          Icons.delete,
                          size: 16,
                        ),
                      ),
                    )
                  ]));
        } else if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(
                title: Container(),
              ),
              body: Container(
                padding: const EdgeInsets.all(20),
                child: const Text('Error', style: TextStyle(fontSize: 20)),
              ));
        } else {
          return Scaffold(
              appBar: AppBar(
                title: Container(),
              ),
              body: Container());
        }
      },
    );
  }
}

Widget getWorkLogItem(DoneLogItem doneLogItem) {
  return Card(
    child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: const Icon(Icons.check,
                          color: Colors.green, size: 20)),
                  Text(
                    doneLogItem.displayName,
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text('${doneLogItem.lapTime}(${doneLogItem.lapRest})s',
                style: const TextStyle(fontSize: 16)),
          ],
        )),
  );
}
