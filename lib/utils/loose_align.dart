import 'package:flutter/material.dart';

class _LooseAlignDelegate extends SingleChildLayoutDelegate {
  final Alignment alignment;
  const _LooseAlignDelegate(this.alignment);
  @override
  bool shouldRelayout(covariant _LooseAlignDelegate oldDelegate) => false;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(Size(double.infinity, double.infinity));

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
      (size.width - childSize.width) * (alignment.x + 1) / 2, (size.height - childSize.height) * (alignment.y + 1) / 2);
}

/// 宽松拉伸，取消所有约束，使子Widget可以具有超出屏幕的大小，取决于子Widget本身。
class LooseExpanded extends CustomSingleChildLayout {
  LooseExpanded({Alignment alignment = Alignment.center, Widget? child, Key? key})
      : super(delegate: _LooseAlignDelegate(alignment), child: child, key: key);
}
