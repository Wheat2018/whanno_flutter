import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen/fullscreen.dart';

Future<void> _fullscreen() async {
  await (await _isFullscreen()
      ? FullScreen.exitFullScreen()
      : FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY));
}

Future<bool> _isFullscreen() async => await FullScreen.isFullScreen == true;

Widget fullscreenButton() {
  return FutureBuilder<bool>(
    builder: (context, snapshot) {
      return IconButton(
          onPressed: () async => await _fullscreen(),
          icon: Icon(snapshot.data == true ? Icons.fullscreen_exit : Icons.fullscreen));
    },
    initialData: false,
    future: _isFullscreen(),
  );
}
