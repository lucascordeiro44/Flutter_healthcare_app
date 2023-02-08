import 'dart:io';

import 'package:image/image.dart';

//https://pub.dev/packages/image#-readme-tab-
resizeImage(File from, File to) {
  // Read an image from file (webp in this case).
  // decodeImage will identify the format of the image and use the appropriate
  // decoder.
  Image image = decodeImage(from.readAsBytesSync());

  // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
  Image thumbnail = copyResize(image, width: 200);

  // Save the thumbnail as a PNG.
  to.writeAsBytesSync(encodePng(thumbnail));
}
