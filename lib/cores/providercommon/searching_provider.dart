import 'package:chatapp/models/chat_user.dart';
import 'package:flutter/material.dart';

class SearchingProvider extends ChangeNotifier {
  final List<ChatUser> _list = [];

  List<ChatUser> get list => _list;
  final List<ChatUser> _searchList = [];
  List<ChatUser> get searchList => _searchList;

  // setList(data) {
  //   _list = data;
  // }
  addToList(data) {
    _list.add(data);
    notifyListeners();
  }

  clearList() {
    _list.clear();
    notifyListeners();
  }

  searchData(String keywords) {
    _searchList.clear();

    for (var i in _list) {
      if (i.name.toLowerCase().contains(keywords) ||
          i.email.toLowerCase().contains(keywords)) {
        _searchList.add(i);
      }
    }
    notifyListeners();
  }

  bool _isSearching = false;
  bool get isSearching => _isSearching;
  isSearchingMethod() {
    _isSearching = !isSearching;
    notifyListeners();
  }
}
