import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheat_flutter/gallery/gallery.dart';
import 'package:wheat_flutter/utils/my_card.dart';
import 'package:wheat_flutter/utils/net_image.dart';

extension on double{
  double get upToZero => this <= 0.0 ? 0.0 : this;
  double when(bool sw) => sw ? this : 0.0;
}

class Cabinet extends StatelessWidget{
  const Cabinet({
    Key key,
    this.horizontalCardPadding=0.0,
    this.verticalCardPadding=8.0,
    this.cardMargin=10,
    this.elevation=1.0,
    this.highlightElevation=2.0,
    this.padding=const EdgeInsets.all(15),
    this.highlightExpansion=8,
    this.scrollDirection=Axis.vertical,
    this.controller,
  }): super(key: key);

  final double horizontalCardPadding;
  final double verticalCardPadding;
  final double cardMargin;
  final double elevation;
  final double highlightElevation;
  final EdgeInsets padding;
  final double highlightExpansion;
  final Axis scrollDirection;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    var gallery = Provider.of<GalleryModel>(context);
    var theme = Theme.of(context);
    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      itemCount: gallery.imageUrls.length,
      itemBuilder: (context, index){
        bool highlight = index == gallery.index;
        return GestureDetector(
          onTap: () => gallery.at(index),
          child: MyCard(
            clipBehavior: Clip.antiAlias,
            color: highlight ? theme.primaryColorLight : theme.primaryColor,
            border: Border.all(color: highlight ? theme.highlightColor : theme.dividerColor, width: 1.0),
            borderOnForeground: true,
            padding: EdgeInsets.symmetric(vertical: verticalCardPadding, horizontal: horizontalCardPadding),
            elevation: highlight ? highlightElevation : elevation,
            radius: BorderRadius.all(Radius.circular(10)),
            margin: scrollDirection == Axis.horizontal ?
            EdgeInsets.only(
              left: index == 0 ? padding.left : cardMargin,
              top: (padding.top - highlightExpansion.when(highlight)).upToZero,
              bottom: (padding.bottom - highlightExpansion.when(highlight)).upToZero,
              right: index == gallery.imageUrls.length ? padding.right : 0,
            ) :
            EdgeInsets.only(
              top: index == 0 ? padding.top : cardMargin,
              left: (padding.left - highlightExpansion.when(highlight)).upToZero,
              right: (padding.right - highlightExpansion.when(highlight)).upToZero,
              bottom: index == gallery.imageUrls.length ? padding.bottom : 0,
            ),
            child: NetImage(url: gallery.imageUrls[index]),
          ),
        );
      },
    );
  }
}

class CabinetCard extends StatelessWidget{
  const CabinetCard({
    Key key,
    this.margin,
    this.width,
    this.height
  }): super(key: key);

  final EdgeInsetsGeometry margin;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    var controller = ScrollController();
    return MyCard.cupertino(
      glassOpacity: 0.5,
      border: Border.all(color: Theme.of(context).dividerColor),
      height: height,
      width: width,
      margin: margin,
      child: Scrollbar(
        controller: controller,
        child: Cabinet(
          controller: controller,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}