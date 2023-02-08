Future sleep({int ms = 400}) {
  return Future.delayed(Duration(milliseconds: ms));
}

void forlouco(String s) {
  for (int i = 0; i < 5000; i++) {
    print("louco > $i");
  }
}
