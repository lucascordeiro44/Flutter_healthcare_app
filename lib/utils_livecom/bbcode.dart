

import 'package:intl/intl.dart';

/*Html( data: post.mensagem.replaceAll("[b]", "<b>").replaceAll("[/b]", "</b>") ?? "")*/

readTimestamp(int timestamp) {
  var now = new DateTime.now();
  var format = new DateFormat('HH:mm');
  var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
  var diff = date.difference(now);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + 'DAY AGO';
    } else {
      time = diff.inDays.toString() + 'DAYS AGO';
    }
  }
  return time;
}