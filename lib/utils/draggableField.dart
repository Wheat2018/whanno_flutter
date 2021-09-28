import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _DelegateTest extends SingleChildLayoutDelegate {
  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => true;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    var s = super.getConstraintsForChild(constraints);
    print("getConstraintsForChild: $constraints, $s");
    return BoxConstraints.loose(Size(double.infinity, double.infinity));
  }

  @override
  Size getSize(BoxConstraints constraints) {
    var s = super.getSize(constraints);
    print("getSize: $constraints, $s");
    return s;
  }
}

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
    return Align(
      alignment: widget.alignment,
      child: Consumer<_ScaleValue>(
        builder: (context, value, child) {
          value.childContext = context;
          return Transform.translate(
              offset: value.offset,
              child: Transform.scale(
                scale: value.scale,
                child: child,
                alignment: Alignment.topLeft,
              ));
        },
        child: child,
      ),
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
            var normal = value.convert(e.position);
            value.scale *= 1 - e.scrollDelta.dy.clamp(-50, 50) / 50;
            value.offset += normal * (oldScale - value.scale);
          }
        },
        child: GestureDetector(
          onScaleStart: (details) {
            downOffset = value.offset;
            down = details.focalPoint;
            normal = value.convert(down);
            downScale = value.scale;
          },
          onScaleUpdate: (details) {
            value.scale = downScale * details.scale;
            value.offset = downOffset + details.focalPoint - down + normal * (downScale - value.scale);
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

  double _scale = 1.0;
  double get scale => _scale;
  set scale(double value) {
    value = value.clamp(0.1, 100);
    if (value != _scale) {
      _scale = value;
      notifyListeners();
    }
  }

  BuildContext? childContext;

  RenderBox? get _box => childContext?.findRenderObject() as RenderBox?;

  Offset globalToLocal(Offset global) => _box?.globalToLocal(global) ?? global;

  Offset localToGlobal(Offset local) => _box?.globalToLocal(local) ?? local;

  Offset convert(Offset global) => (globalToLocal(global) - offset) / scale;

  Size get size => (_box?.size ?? Size.zero) * scale;
}

class ScaleController extends ChangeNotifier {
  _ScaleValue? __value;

  _ScaleValue get _value => __value ?? _ScaleValue();

  Offset get offset => _value.offset;
  set offset(Offset v) => _value.offset = v;

  double get scale => _value.scale;
  set scale(double v) => _value.scale = v;

  Size get size => _value.size;

  Offset convert(Offset global) => _value.convert(global);
  Offset globalToLocal(Offset global) => _value.globalToLocal(global);
  Offset localToGlobal(Offset local) => _value.localToGlobal(local);

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
