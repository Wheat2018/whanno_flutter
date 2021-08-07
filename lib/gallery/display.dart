import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whanno_flutter/utils/draggableField.dart';
import 'package:whanno_flutter/utils/my_card.dart';
import 'package:whanno_flutter/utils/net_image.dart';

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
      child: Consumer<GalleryModel>(
          builder: (context, gallery, child) => DraggableField(
            builder: (context, listen){
              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    color: Color.fromRGBO(0, 0, 0, 0),
                  ),
                  listen(
                    Consumer<GalleryModel>(
                      builder: (context, gallery, child) => NetImage(
                        url: gallery.current,
                      ),
                    ),
                  ),
                ],
              );
            },
          )
      ),
    );
  }
}
