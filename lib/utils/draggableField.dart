import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DraggableField extends StatefulWidget {
  final Widget Function(BuildContext context, Widget Function(Widget child) apply) builder;

  final Alignment alignment;
  final ScaleController controller;
  final HitTestBehavior? behavior;

  DraggableField({
    Key? key,
    required this.builder,
    this.alignment = Alignment.center,
    ScaleController? controller,
    this.behavior = HitTestBehavior.translucent,
  })  : controller = controller ?? ScaleController(),
        super(key: key);

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
    var downScale = 1.0;
    Offset? normal;
    return ChangeNotifierProvider(
      create: (_) => value,
      child: Listener(
        onPointerSignal: (e) {
          if (e is PointerScrollEvent) {
            var scale = e.scrollDelta.dy.clamp(-50, 50) / 50;
            scale = scale <= 0 ? 1 - scale : 1 / (1 + scale);
            value.zoom(normal ?? value.globalToNormal(e.position), value.scale * scale);
          }
        },
        child: GestureDetector(
          behavior: widget.behavior,
          onScaleStart: (details) {
            down = details.focalPoint;
            normal = value.globalToNormal(down);
            downScale = value.scale;
          },
          onScaleUpdate: (details) {
            value.translate(details.focalPoint - down);
            if (details.scale != 1.0) value.zoom(normal!, downScale * details.scale);
            down = details.focalPoint;
          },
          onScaleEnd: (details) {
            normal = null;
          },
          child: widget.builder(context, _dragListener),
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

  void translate(Offset offset) => this.offset += offset;

  void zoom(Offset normal, double newScale) {
    var oldScale = scale;
    scale = newScale;
    offset += normal * (oldScale - scale);
  }

  BuildContext? childContext;

  RenderBox? get _box => childContext?.findRenderObject() as RenderBox?;

  Offset globalToLocal(Offset global) => _box?.globalToLocal(global) ?? global;

  Offset globalToNormal(Offset global) => (globalToLocal(global) - offset) / scale;

  Offset localToGlobal(Offset local) => _box?.localToGlobal(local) ?? local;

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

  Offset globalToNormal(Offset global) => _value.globalToNormal(global);
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
