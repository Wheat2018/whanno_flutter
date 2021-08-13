import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  const NetImage({
    Key? key,
    required this.url,
    this.color,
    this.filterQuality = FilterQuality.high,
  }) : super(key: key);

  final String url;
  final Color? color;
  final FilterQuality filterQuality;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      filterQuality: filterQuality,
      loadingBuilder: (context, child, loadingProgress) {
        if (((child as Semantics).child as RawImage).image != null) return child;
        return Center(
          widthFactor: 1.5,
          heightFactor: 1.5,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(color ?? Theme.of(context).accentColor),
            value: loadingProgress?.expectedTotalBytes != null
                ? loadingProgress!.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, obj, errStack) => Icon(Icons.error),
    );
  }
}
