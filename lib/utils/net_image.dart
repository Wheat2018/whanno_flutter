import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class NetImage extends StatelessWidget{
  const NetImage({
    Key key,
    this.url,
    this.color,
  }): super(key: key);

  final String url;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      loadingBuilder: (context, child, loadingProgress) {
        if (((child as Semantics).child as RawImage).image != null) return child;
        return Center(
          widthFactor: 1.5,
          heightFactor: 1.5,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(color ?? Theme.of(context).accentColor),
            value: loadingProgress?.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                : null,
          ),
        );
      },
    );
  }

}