import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  const NetImage({
    Key? key,
    required this.url,
    this.scale = 1.0,
    this.color,
    this.filterQuality = FilterQuality.high,
    this.fit,
  }) : super(key: key);

  final String url;
  final double scale;
  final Color? color;
  final FilterQuality filterQuality;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      scale: scale,
      fit: fit,
      filterQuality: filterQuality,
      loadingBuilder: (context, child, loadingProgress) {
        if (((child as Semantics).child as RawImage).image != null) return child;
        return Center(
          widthFactor: 1.5,
          heightFactor: 1.5,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(color ?? Theme.of(context).colorScheme.secondary),
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
