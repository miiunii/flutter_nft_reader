import 'package:flutter/material.dart';
import 'dart:async';

class CustomTimer extends ChangeNotifier{

  double currentTime = 0.0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void start() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentTime += 0.1;
      notifyListeners();
    });
  }

  void pause() {
    timer?.cancel();
  }

  void reset() {
    timer?.cancel();
    currentTime = 0.0;
    notifyListeners();
  }
}
