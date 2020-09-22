import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'workout_store_test.dart' as sqflite_test;

void main() {
  final completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('driver', () {
    sqflite_test.main();
  });
}
