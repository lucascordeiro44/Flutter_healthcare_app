import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String imagePath;
  final ImageProvider imageProvider;

  const ImageViewer({Key key, this.imagePath, this.imageProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: PhotoView(
          imageProvider:
              imageProvider != null ? imageProvider : AssetImage(imagePath),
        ),
      ),
    );
  }
}
