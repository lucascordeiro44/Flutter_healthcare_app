import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/progress.dart';

class AppCircleAvatar extends StatelessWidget {
  final String avatar;
  final String assetAvatarNull;
  final bool dafaultImage;
  final double radius;

  const AppCircleAvatar({
    Key key,
    @required this.avatar,
    this.dafaultImage = true,
    this.assetAvatarNull = 'assets/images/without-avatar.png',
    this.radius = 55.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return avatar == null || avatar == "" || !avatar.startsWith('http')
        ? CircleAvatar(
            backgroundColor: Colors.white,
            radius: radius,
            backgroundImage: dafaultImage
                ? AssetImage(assetAvatarNull)
                : FileImage(File(assetAvatarNull)))
        : CachedNetworkImage(
            useOldImageOnUrlChange: true,
            fadeInDuration: Duration(seconds: 0),
            fadeOutDuration: Duration(seconds: 0),
            placeholderFadeInDuration: Duration(seconds: 0),
            imageUrl: avatar,
            placeholder: (context, url) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: radius,
                child: Progress(),
              );
            },
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: radius,
                backgroundImage: imageProvider,
              );
            },
          );
  }
}
