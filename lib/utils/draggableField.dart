import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DraggableField extends StatefulWidget {
  ///第二个参数为监听控件
  final Widget Function(BuildContext context, Widget Function(Widget) apply) builder;

  final Alignment alignment;

  DraggableField({Key? key, required this.builder, this.alignment = Alignment.center, ScaleController? controller})
      : controller = controller ?? ScaleController(),
        super(key: key);

  final ScaleController controller;

  @override
  _DraggableFieldState createState() => _DraggableFieldState();
}

class _DraggableFieldState extends State<DraggableField> {
  final _ScaleValue value = _ScaleValue();
  @override
  void initState() {
    widget.controller.attach(value);
    super.initState();
  }

  Widget _dragListener(Widget child) {
    return Consumer<_ScaleValue>(
      builder: (context, controller, child) {
        return Transform.translate(
            offset: controller.inherent + controller.offset,
            child: Transform.scale(
              scale: controller.scale,
              child: child,
              alignment: Alignment.topLeft,
            ));
      },
      child: child,
    );
  }

  @override
  void didUpdateWidget(covariant DraggableField oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.detach();
      widget.controller.attach(value);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var down = Offset.zero;
    var downOffset = Offset.zero;
    var downScale = 1.0;
    var normal = Offset.zero;
    return ChangeNotifierProvider(
      create: (_) => value,
      child: Listener(
        onPointerSignal: (e) {
          if (e is PointerScrollEvent) {
            var oldScale = value.scale;
            var normal = value.convert(e.localPosition);
            var wheelScale = -e.scrollDelta.dy.clamp(-50, 50) / 50;
            value.scale *= 1 + wheelScale;
            value.offset += normal * (oldScale - value.scale);
          }
        },
        child: GestureDetector(
          onScaleStart: (details) {
            downOffset = value.offset;
            down = details.localFocalPoint;
            normal = value.convert(down);
            downScale = value.scale;
          },
          onScaleUpdate: (details) {
            value.scale = downScale * details.scale;
            value.offset = downOffset + details.localFocalPoint - down + normal * (downScale - value.scale);
          },
          child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: widget.builder(context, _dragListener)),
        ),
      ),
    );
  }
}

class _ScaleValue extends ChangeNotifier {
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(Offset value) {
    if (value != _offset) {
      _offset = value;
      notifyListeners();
    }
  }

  Offset _inherent = Offset.zero;
  Offset get inherent => _inherent;
  set inherent(Offset value) {
    if (value != _inherent) {
      _inherent = value;
      notifyListeners();
    }
  }

  double _scale = 1.0;
  double get scale => _scale;
  set scale(double value) {
    value = value.clamp(0.1, 100);
    if (value != _scale) {
      _scale = value;
      notifyListeners();
    }
  }

  Offset convert(Offset local) => (local - offset - inherent) / scale;
}

class ScaleController extends ChangeNotifier {
  _ScaleValue? __value;

  _ScaleValue get _value => __value ?? _ScaleValue();

  Offset get offset => _value.offset;
  set offset(Offset v) => _value.offset = v;

  Offset get inherent => _value.inherent;
  set inherent(Offset v) => _value.inherent = v;

  double get scale => _value.scale;
  set scale(double v) => _value.scale = v;

  Offset convert(Offset local) => _value.convert(local);

  void attach(_ScaleValue value) {
    __value = value;
    value.addListener(notifyListeners);
  }

  void detach() {
    __value?.removeListener(notifyListeners);
    __value = null;
  }

  static ScaleController of(BuildContext context, {bool listen = true}) =>
      Provider.of<ScaleController>(context, listen: listen);
}
