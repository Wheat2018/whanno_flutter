import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndicatorImage extends Image {
  IndicatorImage(
    ImageProvider image, {
    Key? key,
    Color? color,
    FilterQuality filterQuality = FilterQuality.high,
    BoxFit? fit,
    double? width,
    double? height,
  }) : super(
          key: key,
          image: image,
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
          width: width,
          height: height,
        );
}
