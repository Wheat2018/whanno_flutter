import 'package:flutter/material.dart';
import 'package:whanno_flutter/utils/draggableField.dart';
import 'package:whanno_flutter/utils/my_card.dart';
import 'package:whanno_flutter/utils/indicator_image.dart';

import 'gallery.dart';

class Display extends StatelessWidget {
  const Display({
    Key? key,
    this.margin,
  }) : super(key: key);
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return DraggableField(
      builder: (context, listen) {
        return MyCard.cupertino(
          margin: margin,
          child: Stack(
            children: [listen(IndicatorImage(NetworkImage(GalleryModel.of(context).current)))],
          ),
        );
      },
    );
  }
}
