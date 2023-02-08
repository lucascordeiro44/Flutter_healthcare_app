
import 'dart:math';

int random() {
  String s = "";
  var rng = new Random();
  for (var i = 0; i < 10; i++) {
    s += rng.nextInt(10).toString();
  }
  return int.parse(s);
}
