import 'package:flutter/material.dart';

class AnimatedIconProvider extends ChangeNotifier {
  bool _isAnimate = true;
  bool get isAnimate => _isAnimate;
  isAnimateFunction() {
    Future.delayed(const Duration(milliseconds: 700), () {
      _isAnimate = false;
      notifyListeners();
    });
  }
}
