import 'package:flutter/material.dart';

import 'orders.dart';
import 'restaurants.dart';

class Cart extends ChangeNotifier {
  var itemsMap = <Restaurant, List<OrderItem>>{};

  void checkInitMap(Restaurant restaurant) {
    if (itemsMap[restaurant] == null) {
      itemsMap[restaurant] = <OrderItem>[];
    }
  }

  void addToCart(Restaurant restaurant, OrderItem orderItem) {
    checkInitMap(restaurant);
    itemsMap[restaurant].add(orderItem);
    notifyListeners();
  }

  double getTotal(Restaurant restaurant) {
    checkInitMap(restaurant);

    var sum = 0.00;

    for (var item in itemsMap[restaurant]) {
      sum += double.parse(item.price);
    }

    return sum;
  }

  int getQuantity(Restaurant restaurant) {
    checkInitMap(restaurant);

    var quantity = 0;
    for (var item in itemsMap[restaurant]) {
      quantity += item.quantity;
    }
    return quantity;
  }

  void remove(Restaurant restaurant, OrderItem item) {
    checkInitMap(restaurant);

    itemsMap[restaurant].remove(item);
    notifyListeners();
  }

  void clearCart(Restaurant restaurant) {
    checkInitMap(restaurant);
    itemsMap[restaurant].clear();
    notifyListeners();
  }
}
