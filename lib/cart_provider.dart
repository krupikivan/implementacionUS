import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'item.dart';

class CartProvider with ChangeNotifier {
  final List<Item> _items = [];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  int get totalPrice {
    int precio = 0;
    _items.forEach((element) {
      precio += element.precio;
    });
    return precio;
  }

  bool _efectivo = false;

  bool get efectivoPago => _efectivo;

  void change(bool val) {
    _efectivo = val;
    notifyListeners();
  }

  void add(Item item) {
    _items.contains(item) ? _items.remove(item) : _items.add(item);
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }
}
