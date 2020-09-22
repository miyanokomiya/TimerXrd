import 'package:TimerXrd/models/done_log.dart';
import 'package:flutter/material.dart';
import './store/workout_store.dart';
import './utils/datetime.dart';

class DoneLogDetailPage extends StatelessWidget {
  final int id;

  const DoneLogDetailPage({Key key, @required this.id}) : super(key: key);

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
              ])));
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
            Text('${doneLogItem.lapTime}s',
                style: const TextStyle(fontSize: 16)),
          ],
        )),
  );
}
