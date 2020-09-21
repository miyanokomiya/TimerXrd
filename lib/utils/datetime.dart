String formatSeconds(int seconds) {
  final h = (seconds / (60 * 60)).floor();
  final m = ((seconds % (60 * 60)) / 60).floor();
  final s = seconds % 60;
  final hText = h > 0 ? '$h:' : '';
  return '$hText${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatDateTime(DateTime d) {
  final l = d.toLocal();
  return '${formatDate(d)} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${l.month.toString().padLeft(2, '0')}/${l.day.toString().padLeft(2, '0')}';
}
