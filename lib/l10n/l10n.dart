import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import './l10n_delegate.dart';
import './messages_all.dart';

/// アプリでの文言はこれ経由で取得する
class L10n {
  /// 言語リソースを扱う
  ///
  /// localeは端末設定・アプリの指定を踏まえて最適なものが渡ってくる
  static Future<L10n> load(Locale locale) async {
    final name = locale.countryCode == null || locale.countryCode.isEmpty
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    // 言語リソース読み込み
    await initializeMessages(localeName);
    // デフォルト言語を設定
    Intl.defaultLocale = localeName;
    // 自身を返す
    return L10n();
  }

  // Widgetツリーから自身を取り出す
  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = L10nDelegate();

  // 以下、Intl.messageを用いて必要な文言を返すgetter・メソッドを定義

  String get ready => Intl.message(
    'Ready',
    name: 'ready',
  );
  String get finish => Intl.message(
    'Finish',
    name: 'finish',
  );
  String get goodJob => Intl.message(
    'Good Job',
    name: 'goodJob',
  );
  String get workouts => Intl.message(
    'Workouts',
    name: 'workouts',
  );
  String get quickRun => Intl.message(
    'Quick Run',
    name: 'quickRun',
  );
  String get noName => Intl.message(
    'no name',
    name: 'noName',
  );
  String get save => Intl.message(
    'Save',
    name: 'save',
  );
  String get delete => Intl.message(
    'Delete',
    name: 'delete',
  );
  String get discard => Intl.message(
    'Discard',
    name: 'discard',
  );
  String get workout => Intl.message(
    'Workout',
    name: 'workout',
  );
  String get lap => Intl.message(
    'Lap',
    name: 'lap',
  );
  String get name => Intl.message(
    'Name',
    name: 'name',
  );
  String get time => Intl.message(
    'Time',
    name: 'time',
  );
  String get rest => Intl.message(
    'Rest',
    name: 'rest',
  );
  String get editLap => Intl.message(
    'Edit Lap',
    name: 'editLap',
  );
  String get leftAndRight => Intl.message(
    'Left and Right',
    name: 'leftAndRight',
  );
  String get confirmDeleteWorkout => Intl.message(
    'Are you sure to delete this workout?',
    name: 'confirmDeleteWorkout',
  );
  String get confirmDiscardChanges => Intl.message(
        'Will you discard your changes?',
        name: 'confirmDiscardChanges',
      );
}
