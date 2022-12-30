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

  void start(String interval) {
    double duration = double.parse(interval);
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {

      if (currentTime >= duration) {
        currentTime -= 0.1;
        pause();
        }

        currentTime += 0.1;
        notifyListeners();
    });
  }

  void pause() {
    timer?.cancel();
  }

  void reset() {
    currentTime = 0.0;
    timer?.cancel();
    notifyListeners();
  }
}
