import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  isLoadingFunction() {
    _isLoading = !isLoading;
    notifyListeners();
  }
}
