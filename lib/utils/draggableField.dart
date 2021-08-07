import 'dart:math';

import 'package:flutter/material.dart';

class DeltaValue<T extends num>{
  late T _data;
  final T? min, max;
  DeltaValue(T data, {this.min, this.max}){
    _data = data;
    _last = data;
  }
  T get current => _data;

  late T _pinned;
  late T _origin;
  late T _last;
  T get last => _last;
  void start(T origin){
    _pinned = current;
    _origin = origin;
  }

  T state(T now){
    _last = _data;
    _data = (_pinned + now - _origin) as T;
    if (min != null && _data < min!) _data = min!;
    if (max != null && _data > max!) _data = max!;
    return _data;
  }
}

class DraggableField<T extends Widget> extends StatefulWidget{
  ///第二个参数为监听控件
  final Widget Function(BuildContext, Widget Function(Widget)) builder;

  final Point<double> startPosition;

  const DraggableField({Key? key, required this.builder, this.startPosition = const Point(0.0, 0.0)}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DraggableFieldState<T>();
}

class _DraggableFieldState<T extends Widget> extends State<DraggableField<T>>{
  var down = const Offset(0, 0);
  var scale = DeltaValue(1.0, min: 0.1);
  late Point<double> position;
  late final Widget Function(Widget) _listen;

  @override
  void initState() {
    super.initState();
    position = widget.startPosition;
    _listen = (child) {
      // print(position);
      return Container(
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: position.x,
              top: position.y,
              child: Transform(
                origin: Offset(down.dx - position.x, down.dy - position.y),
                transform: Matrix4.identity()..scale(scale.current, scale.current),
                child: child,
              ),
            ),
          ],
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details){
        down = details.localFocalPoint;
        scale.start(1.0);
      },
      onScaleUpdate: (details){
        setState(() {
          position = position + Point(details.localFocalPoint.dx - down.dx, details.localFocalPoint.dy - down.dy);
          down = details.localFocalPoint;
          scale.state(details.scale);
        });
      },
      child: widget.builder(context, _listen)
      // child: CustomSingleChildLayout(
      //   delegate: ,
      //   child: widget.builder(context, _listen),
      // ),
    );
  }

}

class DraggableFieldRelayout extends SingleChildLayoutDelegate{
  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    throw UnimplementedError();
  }

}