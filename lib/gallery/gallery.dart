import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GalleryModel extends ChangeNotifier {
  final List<String> _imageUrls = [
    "https://i.loli.net/2021/01/02/h1nSoTMjuYW8DN6.gif",
    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20180705%2Fa66d2b9cae954d89b3c71030ecbc3599.gif&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1631418223&t=c94546788e1d3f7075aef1b76ae58d22",
    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fnimg.ws.126.net%2F%3Furl%3Dhttp%253A%252F%252Fdingyue.ws.126.net%252F2021%252F0722%252F02e78f11j00qwmvp80017c000m800m8m.jpg%26thumbnail%3D650x2147483647%26quality%3D80%26type%3Djpg&refer=http%3A%2F%2Fnimg.ws.126.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1630569509&t=3af8588c1bb199c76009c080a3aab3f0",
    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_bt%2F0%2F13483889702%2F1000.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1630061409&t=70159ff1457e9d430ab96b887d3e36d0",
    "https://github.com/flutter/plugins/raw/master/packages/video_player/video_player/doc/demo_ipod.gif?raw=true",
    "https://via.placeholder.com/350x150",
    "https://picsum.photos/250?image=9",
    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_bt%2F0%2F13483889702%2F1000.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1630061409&t=70159ff1457e9d430ab96b887d3e36d0",
    "https://via.placeholder.com/350x150",
  ];
  int _index = 0;

  UnmodifiableListView get imageUrls => UnmodifiableListView(_imageUrls);
  int get index => _index;
  String get current => imageUrls[index];

  void add(String url) {
    _imageUrls.add(url);
    notifyListeners();
  }

  void remove(int index) {
    if (index >= 0 && index < imageUrls.length) {
      _imageUrls.removeAt(index);
      notifyListeners();
    }
  }

  void setTo(int index) {
    if (index >= 0 && index < imageUrls.length) {
      this._index = index;
      notifyListeners();
    }
  }

  static GalleryModel of(BuildContext context, {bool listen = true}) => Provider.of(context, listen: listen);
}
