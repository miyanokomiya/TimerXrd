import 'package:TimerXrd/models/done_log.dart';
import 'package:flutter/material.dart';
import './done_log_detail_page.dart';
import './l10n/l10n.dart';
import './store/workout_store.dart';
import './utils/datetime.dart';

class DoneLogListPage extends StatefulWidget {
  @override
  _DoneLogListPageState createState() => _DoneLogListPageState();
}

class _DoneLogListPageState extends State<DoneLogListPage> {
  DateTime from;
  DateTime to;
  List<DoneLog> doneLogs = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    from = DateTime(now.year, now.month - 1, now.day).toUtc();
    to = DateTime(now.year, now.month, now.day + 1).toUtc();
    loadDoneLogs();
  }

  Future<void> loadDoneLogs() async {
    final _doneLogs = await getDoneLogs(from, to);
    setState(() {
      doneLogs = _doneLogs;
    });
  }

  int get totalCount => doneLogs.length;

  int get totalTime => doneLogs.isNotEmpty
      ? doneLogs
          .map((e) => e.workoutTotalTime)
          .reduce((value, element) => value + element)
      : 0;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(formatDate(from), style: const TextStyle(fontSize: 24)),
              const Text(' ~ ', style: TextStyle(fontSize: 20)),
              Text(formatDate(to.add(const Duration(milliseconds: -1))),
                  style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
        body: Center(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$totalCount ${l10n.times}',
                    style: const TextStyle(fontSize: 20)),
                Container(
                    width: 20,
                    alignment: Alignment.center,
                    child: const Text('/', style: TextStyle(fontSize: 20))),
                Text(formatSeconds(totalTime),
                    style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
              child: ListView(
                  children: doneLogs
                      .map((e) =>
                          getWorkLogItem(context, e, onDelete: loadDoneLogs))
                      .toList()))
        ])));
  }
}

Widget getWorkLogItem(BuildContext context, DoneLog doneLog,
    {@required void Function() onDelete}) {
  return Card(
      child: InkWell(
    onTap: () async {
      final deleted = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoneLogDetailPage(id: doneLog.id)));
      if (deleted == true) {
        onDelete();
      }
    },
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
                    doneLog.displayName,
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(formatDateTime(doneLog.createdAt),
                style: const TextStyle(fontSize: 16)),
          ],
        )),
  ));
}
