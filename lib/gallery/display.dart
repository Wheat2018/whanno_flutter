import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whanno_flutter/models/labels_viewer.dart';
import 'package:whanno_flutter/utils/draggableField.dart';
import 'package:whanno_flutter/utils/loose_align.dart';
import 'package:whanno_flutter/utils/my_card.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';
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
    var controller = ScaleController.of(context, listen: false);
    return MyCard.cupertino(
      margin: margin,
      child: MouseRegion(
        child: DraggableField(
          builder: (context, apply) {
            return Stack(
              children: [
                LooseExpanded(
                  child: apply(Consumer<GalleryModel>(builder: (context, gallery, child) {
                    var instances = gallery.current.label?.skipNull();
                    var image = gallery.current.image?.get();
                    if (instances == null || image == null) return Icon(Icons.error);
                    return CustomPaint(
                      foregroundPainter: _Painter(instances),
                      child: IndicatorImage(image),
                    );
                  })),
                )
              ],
            );
          },
          controller: controller,
        ),
        onExit: (e) {
          print("exit");
          var gallery = GalleryModel.of(context, listen: false);
          var instance = gallery.current.label?[0];
          if (instance == null) return;
          instance[0] = instance[1] = instance[2] = instance[3] = "0";
          gallery.notifyListeners();
        },
        onHover: (e) {
          print("hover");
          var gallery = GalleryModel.of(context, listen: false);
          var instance = gallery.current.label?[0];
          if (instance == null) return;
          // print(await gallery.current.image?.get()?.size);
          Offset pos = controller.globalToNormal(e.position);
          // print("${e.localPosition}, $pos, ${e.down}");
          instance[0] = pos.dx.toString();
          instance[1] = pos.dy.toString();
          instance[2] = (pos.dx + 350).toString();
          instance[3] = (pos.dy + 150).toString();
          gallery.notifyListeners();
        },
      ),
    );
  }
}

class _Painter extends CustomPainter {
  Iterable<InstanceLabelDispatcher> instances;
  _Painter(this.instances);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = Colors.green
      ..invertColors = false;
    instances.forEach((e) => e.draw(canvas, size, paint));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
