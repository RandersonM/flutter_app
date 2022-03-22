// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  set counter(int newCounter) {
    _counter = newCounter;
    notifyListeners();
  }

  void increment() {
    counter = _counter + 1;
  }
}
