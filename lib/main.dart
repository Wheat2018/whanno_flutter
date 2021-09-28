import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whanno_flutter/gallery/cabinet.dart';
import 'package:whanno_flutter/gallery/display.dart';
import 'package:whanno_flutter/gallery/gallery.dart';
import 'package:whanno_flutter/utils/draggableField.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => GalleryModel()),
      ChangeNotifierProvider(create: (context) => ScaleController())
    ],
    child: MyApp(),
  ));
}

enum CabinetLayoutStyle { floating, fixed }

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CabinetLayoutStyle cabinetLayoutStyle = CabinetLayoutStyle.fixed;
  final Key display = GlobalKey(debugLabel: 'display');
  final Key cabinet = GlobalKey(debugLabel: 'cabinet');

  List<Widget> getChildren(BuildContext context, Orientation orientation) {
    bool vertical = orientation == Orientation.portrait;
    List<Widget> children;
    switch (cabinetLayoutStyle) {
      case CabinetLayoutStyle.fixed:
        children = <Widget>[
          Expanded(
            child: Display(
              key: display,
              margin: EdgeInsets.only(left: 10, right: vertical ? 10 : 0, top: 10, bottom: vertical ? 0 : 10),
            ),
          ),
          CabinetCard(
            key: cabinet,
            scrollDirection: vertical ? Axis.horizontal : Axis.vertical,
            height: vertical ? 150 : null,
            width: vertical ? null : 150,
            margin: EdgeInsets.all(10),
          ),
        ];
        break;
      case CabinetLayoutStyle.floating:
        children = <Widget>[
          Expanded(
            child: Stack(
              alignment: vertical ? AlignmentDirectional.bottomCenter : AlignmentDirectional.centerEnd,
              children: [
                Display(
                  key: display,
                  margin: EdgeInsets.all(10),
                ),
                CabinetCard(
                  key: cabinet,
                  scrollDirection: vertical ? Axis.horizontal : Axis.vertical,
                  height: vertical ? 150 : null,
                  width: vertical ? null : 150,
                  margin: EdgeInsets.all(20),
                ),
              ],
            ),
          ),
        ];
        break;
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wheat',
      theme: ThemeData.dark().copyWith(shadowColor: Colors.black54, platform: TargetPlatform.iOS),
      routes: {
        '/home': (context) => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      setState(() {
                        cabinetLayoutStyle = cabinetLayoutStyle == CabinetLayoutStyle.fixed
                            ? CabinetLayoutStyle.floating
                            : CabinetLayoutStyle.fixed;
                      });
                    },
                    icon: Icon(Icons.transform)),
                title: Consumer<ScaleController>(
                  builder: (context, controller, child) =>
                      Text("${controller.scale}, ${controller.size}, ${controller.offset}"),
                ),
              ),
              body: OrientationBuilder(
                builder: (context, orientation) {
                  return Center(
                    child: Flex(
                      direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: getChildren(context, orientation),
                    ),
                  );
                },
              ),
            )
      },
      initialRoute: '/home',
    );
  }
}
