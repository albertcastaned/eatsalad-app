import 'package:flutter/material.dart';

import 'orders.dart';

class Cart extends ChangeNotifier {
  List<OrderItem> items = new List<OrderItem>();

  void addToCart(OrderItem orderItem) {
    items.add(orderItem);
    print(items);
    notifyListeners();
  }

  double getTotal() {
    double sum = 0.00;
    items.forEach((element) {
      sum += double.parse(element.price);
    });
    return sum;
  }

  int getQuantity() {
    int quantity = 0;
    items.forEach((element) {
      quantity += element.quantity;
    });
    return quantity;
  }

  void remove(OrderItem item) {
    items.remove(item);
    notifyListeners();
  }
}
