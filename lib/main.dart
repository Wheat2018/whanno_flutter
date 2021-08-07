import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whanno_flutter/gallery/cabinet.dart';
import 'package:whanno_flutter/gallery/display.dart';
import 'package:whanno_flutter/gallery/gallery.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => GalleryModel()),
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
  CabinetLayoutStyle layoutStyle = CabinetLayoutStyle.fixed;

  List<Widget> getChildren(BuildContext context) {
    var button = RaisedButton(
      onPressed: () {
        setState(() {
          layoutStyle =
              layoutStyle == CabinetLayoutStyle.fixed ? CabinetLayoutStyle.floating : CabinetLayoutStyle.fixed;
        });
      },
      color: Theme.of(context).primaryColor,
      shape: StadiumBorder(side: BorderSide(color: Colors.black)),
      child: Text("滚出中国"),
    );
    List<Widget> children;
    switch (layoutStyle) {
      case CabinetLayoutStyle.fixed:
        children = <Widget>[
          Expanded(
            child: const Display(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
            ),
          ),
          CabinetCard(
            height: 150,
            margin: EdgeInsets.all(10),
          ),
          button,
        ];
        break;
      case CabinetLayoutStyle.floating:
        children = <Widget>[
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const Display(
                  margin: EdgeInsets.all(10),
                ),
                CabinetCard(
                  height: 150,
                  margin: EdgeInsets.all(20),
                ),
              ],
            ),
          ),
          button,
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
                title: Text('wheat home'),
              ),
              body: Builder(
                builder: (context) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: getChildren(context),
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
