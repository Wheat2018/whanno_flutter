import 'dart:html';

import 'package:flutter/material.dart';

void _fullscreen() {
  if (_isFullscreen())
    document.exitFullscreen();
  else
    document.documentElement?.requestFullscreen();
}

bool _isFullscreen() => document.fullscreenElement != null;

Widget fullscreenButton() {
  return IconButton(
      onPressed: () => _fullscreen(), icon: Icon(_isFullscreen() ? Icons.fullscreen_exit : Icons.fullscreen));
}
