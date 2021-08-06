import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheat_flutter/utils/my_card.dart';
import 'package:wheat_flutter/utils/net_image.dart';

import 'gallery.dart';

class Display extends StatelessWidget {
  const Display({
    Key? key,
    this.margin,
  }) : super(key: key);
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return MyCard.cupertino(
      margin: margin,
      child: Center(
        child: NetImage(url: Provider
            .of<GalleryModel>(context)
            .current),
      ),
    );
  }
}
