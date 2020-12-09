import 'package:EatSalad/providers/restaurants.dart';
import 'package:flutter/material.dart';

import 'orders.dart';

class Cart extends ChangeNotifier {
  var itemsMap = <Restaurant, List<OrderItem>>{};

  void checkInitMap(Restaurant restaurant) {
    if (itemsMap[restaurant] == null)
      itemsMap[restaurant] = new List<OrderItem>();
  }

  void addToCart(Restaurant restaurant, OrderItem orderItem) {
    checkInitMap(restaurant);
    itemsMap[restaurant].add(orderItem);
    notifyListeners();
  }

  double getTotal(Restaurant restaurant) {
    checkInitMap(restaurant);

    double sum = 0.00;
    itemsMap[restaurant].forEach((element) {
      sum += double.parse(element.price);
    });
    return sum;
  }

  int getQuantity(Restaurant restaurant) {
    checkInitMap(restaurant);

    int quantity = 0;
    itemsMap[restaurant].forEach((element) {
      quantity += element.quantity;
    });
    return quantity;
  }

  void remove(Restaurant restaurant, OrderItem item) {
    checkInitMap(restaurant);

    itemsMap[restaurant].remove(item);
    notifyListeners();
  }
}
