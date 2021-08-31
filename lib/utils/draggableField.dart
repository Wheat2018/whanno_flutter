import 'package:flutter/material.dart';

class DeltaValue<T extends num> {
  late T _data;
  final T? min, max;
  DeltaValue(T data, {this.min, this.max}) {
    _data = data;
    _prev = data;
  }
  T get current => _data;
  set _current(T value) {
    _prev = current;
    if (min != null && value < min!) value = min!;
    if (max != null && value > max!) value = max!;
    _data = value;
  }

  late T _pinned;
  late T _origin;
  late T _prev;
  T get prev => _prev;
  void start(T origin) {
    _pinned = current;
    _origin = origin;
  }

  T delta(T now) => _current = (_pinned + now - _origin) as T;

  T times(T now) => _current = (_pinned * (now - _origin)) as T;
}

class DraggableField extends StatefulWidget {
  ///第二个参数为监听控件
  final Widget Function(BuildContext, Widget Function(Widget)) builder;

  final Alignment alignment;

  const DraggableField({Key? key, required this.builder, this.alignment = Alignment.center}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DraggableFieldState();
}

class _DraggableFieldState extends State<DraggableField> {
  var nomralizedOffset = Offset.zero;
  var scale = DeltaValue(1.0, min: 0.1);
  Offset offset = Offset.zero;

  Widget dragListener(Widget child) {
    return CustomSingleChildLayout(
      delegate: _DraggableFieldRelayout(offset: offset, scale: scale.current, alignment: widget.alignment),
      child: Transform.scale(
        scale: scale.current,
        child: child,
        alignment: Alignment.topLeft,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onScaleStart: (details) {
          var down = details.localFocalPoint;
          nomralizedOffset = (down - offset) / scale.current;
          scale.start(0);
        },
        onScaleUpdate: (details) {
          setState(() {
            scale.times(details.scale);
            offset = details.localFocalPoint - nomralizedOffset * scale.current;
          });
        },
        child: widget.builder(context, dragListener),
      ),
    );
  }
}

class _DraggableFieldRelayout extends SingleChildLayoutDelegate {
  const _DraggableFieldRelayout({this.offset = Offset.zero, this.scale = 1.0, this.alignment = Alignment.topLeft});

  final Offset offset;

  /// 监听对象的缩放比例，仅用于计算对齐偏移。
  final double scale;

  /// 监听对象对齐方式
  final Alignment alignment;

  @override
  bool shouldRelayout(covariant _DraggableFieldRelayout oldDelegate) {
    return offset != oldDelegate.offset;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Offset alignmentOffset = Offset((size.width - childSize.width) * (alignment.x + 1) / 2,
        (size.height - childSize.height) * (alignment.y + 1) / 2);
    return offset + alignmentOffset * scale;
  }
}
