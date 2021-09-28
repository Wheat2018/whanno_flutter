import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whanno_flutter/gallery/gallery.dart';
import 'package:whanno_flutter/utils/my_card.dart';
import 'package:whanno_flutter/utils/indicator_image.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

extension on double {
  double get upToZero => this <= 0.0 ? 0.0 : this;

  double when(bool sw) => sw ? this : 0.0;
}

class Cabinet extends StatelessWidget {
  const Cabinet({
    Key? key,
    this.controller,
    this.horizontalCardPadding = 0.0,
    this.verticalCardPadding = 8.0,
    this.cardMargin = 10,
    this.elevation = 1.0,
    this.highlightElevation = 2.0,
    this.padding = const EdgeInsets.all(15),
    this.highlightExpansion = 8,
    this.cardRadius = 10,
    this.clipBehavior = Clip.none,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
  }) : super(key: key);

  final ScrollController? controller;
  final double horizontalCardPadding;
  final double verticalCardPadding;
  final double cardMargin;
  final double? elevation;
  final double? highlightElevation;
  final EdgeInsets padding;
  final double highlightExpansion;
  final double cardRadius;
  final Clip clipBehavior;
  final Axis scrollDirection;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryModel>(builder: (context, gallery, child) {
      return ListView.builder(
        clipBehavior: clipBehavior,
        shrinkWrap: shrinkWrap,
        controller: controller,
        scrollDirection: scrollDirection,
        itemCount: gallery.imageUrls.length,
        itemBuilder: (context, index) {
          var theme = Theme.of(context);
          bool highlight = index == gallery.index;
          return GestureDetector(
            onTap: () => gallery.select(index),
            child: MyCard(
              clipBehavior: Clip.antiAlias,
              color: highlight ? theme.primaryColorLight : theme.primaryColor,
              border: Border.all(color: highlight ? theme.highlightColor : theme.dividerColor, width: 1.0),
              borderOnForeground: true,
              padding: EdgeInsets.symmetric(vertical: verticalCardPadding, horizontal: horizontalCardPadding),
              elevation: highlight ? highlightElevation : elevation,
              radius: BorderRadius.all(Radius.circular(cardRadius)),
              margin: scrollDirection == Axis.horizontal
                  ? EdgeInsets.only(
                      left: index == 0 ? padding.left : cardMargin,
                      top: (padding.top - highlightExpansion.when(highlight)).upToZero,
                      bottom: (padding.bottom - highlightExpansion.when(highlight)).upToZero,
                      right: index == gallery.imageUrls.length ? padding.right : 0,
                    )
                  : EdgeInsets.only(
                      top: index == 0 ? padding.top : cardMargin,
                      left: (padding.left - highlightExpansion.when(highlight)).upToZero,
                      right: (padding.right - highlightExpansion.when(highlight)).upToZero,
                      bottom: index == gallery.imageUrls.length ? padding.bottom : 0,
                    ),
              child: (gallery.imageUrls[index].image?.get())
                  .on(notNull: (v) => IndicatorImage(v), justNull: () => Icon(Icons.error)),
            ),
          );
        },
      );
    });
  }
}

class CabinetCard extends StatelessWidget {
  const CabinetCard({Key? key, this.margin, this.width, this.height, this.scrollDirection = Axis.vertical})
      : super(key: key);

  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    var controller = ScrollController();
    return MyCard.cupertino(
      color: Colors.white,
      glassOpacity: 0.3,
      border: Border.all(color: Theme.of(context).dividerColor),
      height: height,
      width: width,
      margin: margin,
      child: Scrollbar(
        controller: controller,
        child: Cabinet(
          controller: controller,
          scrollDirection: scrollDirection,
        ),
      ),
    );
  }
}
