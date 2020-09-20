import 'package:flutter/material.dart';

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
