import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/workout.dart';

Column getLapListItem(BuildContext context, int index, LapItem lapItem) {
  return Column(mainAxisSize: MainAxisSize.min, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(
        child: Text(
          '${index + 1}. ${lapItem.displayName}',
          style: const TextStyle(fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Text('${lapItem.time}s', style: const TextStyle(fontSize: 16)),
    ]),
    const Divider(
      color: Colors.black,
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (lapItem.isLeftAndRight)
          Expanded(
              child: Row(
            children: [
              Text('${index + 2}. ', style: const TextStyle(fontSize: 20)),
              const Text('L',
                  style: TextStyle(fontSize: 20, color: Colors.blue)),
              const Icon(
                Icons.arrow_right,
                color: Colors.blue,
              ),
              const Text('R',
                  style: TextStyle(fontSize: 20, color: Colors.blue)),
            ],
          )),
        Container(
          margin: const EdgeInsets.only(right: 12),
          child:
              Text(L10n.of(context).rest, style: const TextStyle(fontSize: 18)),
        ),
        Text('${lapItem.rest}s', style: const TextStyle(fontSize: 18)),
      ],
    )
  ]);
}
