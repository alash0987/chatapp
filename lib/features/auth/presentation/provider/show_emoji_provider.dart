import 'package:flutter/material.dart';

class ShowEmojiProvider extends ChangeNotifier {
  bool _isShowEmoji = false;
  bool _isUploading = false;
  bool get isUploading => _isUploading;
  isUploadingFunction() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  bool get isShowEmoji => _isShowEmoji;
  showEmoji() {
    _isShowEmoji = !_isShowEmoji;
    notifyListeners();
  }
}
