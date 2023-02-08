import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LinkInfosCard extends StatelessWidget {
  final String imageLink;
  final Color color;
  final String titleLink;
  final String descricao;
  final String url;
  final double heightImg;
  final double widthImg;
  final bool withBorder;

  const LinkInfosCard({
    Key key,
    @required this.imageLink,
    @required this.color,
    @required this.titleLink,
    @required this.descricao,
    @required this.url,
    this.withBorder = true,
    this.heightImg = 70.0,
    this.widthImg = 70.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: withBorder
          ? BoxDecoration(
              border: Border.all(color: Colors.grey[300]),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            )
          : null,
      margin: EdgeInsets.all(0),
      child: Row(
        children: <Widget>[
          imageLink == null
              ? SizedBox()
              : CachedNetworkImage(
                  imageUrl: imageLink,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: heightImg,
                      width: widthImg,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              height: 70,
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    titleLink,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  descricao.isEmpty
                      ? SizedBox(
                          height: 5,
                        )
                      : Text(
                          descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                  Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
