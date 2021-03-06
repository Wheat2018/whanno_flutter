import 'package:flutter/material.dart';
import 'package:whanno_flutter/utils/glass.dart';

class MyCard extends StatelessWidget {
  const MyCard({
    Key? key,
    this.color,
    this.shadowColor,
    this.padding,
    this.margin,
    this.border,
    this.shape = BoxShape.rectangle,
    this.clipBehavior = Clip.none,
    this.radius,
    this.elevation = 1.0,
    this.shadowBlur,
    this.borderOnForeground = false,
    this.glassBlur = 5.0,
    this.glassOpacity = 0.0,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  /// 卡片背景颜色
  final Color? color;

  /// 阴影颜色，默认为主题阴影颜色
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final BoxShape shape;
  final Clip clipBehavior;

  /// 卡片圆角
  final BorderRadiusGeometry? radius;

  /// 卡片阴影抬起程度，置空取消阴影
  final double? elevation;

  /// 卡片阴影模糊程度
  final double? shadowBlur;
  final bool borderOnForeground;

  /// 毛玻璃模糊程度（仅透明度大于0时生效）
  final double glassBlur;

  /// 毛玻璃透明度（大于0开启毛玻璃）
  final double glassOpacity;
  final double? width;
  final double? height;
  final Widget? child;

  const MyCard.cupertino({
    Key? key,
    this.child,
    this.border,
    this.radius = const BorderRadius.all(Radius.circular(10.0)),
    this.margin = const EdgeInsets.all(10),
    this.clipBehavior = Clip.antiAlias,
    this.color,
    this.glassBlur = 5.0,
    this.glassOpacity = 0.0,
    this.elevation = 1.0,
    this.width,
    this.height,
    this.shadowColor,
    this.padding,
  })  : this.shape = BoxShape.rectangle,
        this.shadowBlur = 6.0,
        this.borderOnForeground = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: clipBehavior,
      width: width,
      height: height,
      child: glassOpacity <= 0.0
          ? child
          : Glass(
              color: color ?? Theme.of(context).backgroundColor,
              blur: glassBlur,
              opacity: glassOpacity,
              child: child,
            ),
      decoration: BoxDecoration(
        color: glassOpacity <= 0.0 ? (color ?? Theme.of(context).backgroundColor) : Colors.transparent,
        shape: shape,
        border: borderOnForeground ? null : border,
        borderRadius: radius,
        boxShadow: [
          if (elevation != null)
            BoxShadow(
              color: shadowColor ?? Theme.of(context).shadowColor,
              offset: Offset(2.0, 3.0),
              blurRadius: shadowBlur ?? 6.0,
              spreadRadius: elevation!,
            ),
        ],
      ),
      foregroundDecoration: borderOnForeground
          ? BoxDecoration(
              shape: shape,
              border: border,
              borderRadius: radius,
            )
          : null,
    );
  }
}
