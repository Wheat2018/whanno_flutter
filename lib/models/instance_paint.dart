import 'package:flutter/material.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

import 'labels_viewer.dart';

abstract class InstancePaint {
  static InstancePaint get defaultPaint => RectPaint();
  void draw(Canvas canvas, Size size, Paint paint, InstanceLabelDispatcher instance);
}

enum RectType { LTRB, LTWH }

class RectPaint implements InstancePaint {
  static RectType rectType = RectType.LTRB;
  @override
  void draw(Canvas canvas, Size size, Paint paint, InstanceLabelDispatcher instance) {
    if (instance.length < 4) return;
    var e = instance.toList().sublist(0, 4).map((e) => double.tryParse(e ?? "")).skipNull().toList();
    if (e.length < 4) return;
    switch (rectType) {
      case RectType.LTRB:
        canvas.drawRect(Rect.fromLTRB(e[0], e[1], e[2], e[3]), paint);
        break;
      case RectType.LTWH:
        canvas.drawRect(Rect.fromLTWH(e[0], e[1], e[2], e[3]), paint);
        break;
    }
  }
}
