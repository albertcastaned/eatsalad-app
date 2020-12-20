import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../utils.dart';
import 'restaurants.dart';

class Orders extends ChangeNotifier {
  Future<void> createOrder({
    @required Restaurant restaurant,
    @required List<OrderItem> orderItems,
    @required double subtotal,
    @required double total,
    @required bool payWithCash,
  }) async {
    try {
      final apiUrl = "$server/orders/";
      var token = await FirebaseAuth.instance.currentUser.getIdToken();

      var body = <String, dynamic>{
        'restaurant_input': restaurant.id,
        'total': total,
        'subtotal': subtotal,
        'payWithCash': payWithCash,
        'orderitem_set': [
          for (OrderItem orderItem in orderItems) orderItem.toJson()
        ],
      };
      print(body);
      final response = await apiPost(apiUrl, body, requestApiHeaders(token));
      print(response);
    } catch (error) {
      rethrow;
    }
  }
}

class Order {
  int id;
  String status;
  List<OrderItem> orders;
  Restaurant restaurant;
  Null deliveryDatetime;
  String orderDatetime;
  String subtotal;
  String total;
  bool payWithCash;
  String notes;

  Order(
      {this.id,
      this.status,
      this.orders,
      this.restaurant,
      this.deliveryDatetime,
      this.orderDatetime,
      this.subtotal,
      this.total,
      this.payWithCash,
      this.notes});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    if (json['orderitem_set'] != null) {
      orders = <OrderItem>[];
      json['orderitem_set'].forEach((v) {
        orders.add(OrderItem.fromJson(v));
      });
    }
    restaurant = json['restaurant'] != null
        ? Restaurant.fromJson(json['restaurant'])
        : null;
    deliveryDatetime = json['delivery_datetime'];
    orderDatetime = json['order_datetime'];
    subtotal = json['subtotal'];
    total = json['total'];
    payWithCash = json['payWithCash'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    if (orders != null) {
      data['orderitem_set'] = orders.map((v) => v.toJson()).toList();
    }
    if (restaurant != null) {
      data['restaurant'] = restaurant.toJson();
    }
    data['delivery_datetime'] = deliveryDatetime;
    data['order_datetime'] = orderDatetime;
    data['subtotal'] = subtotal;
    data['total'] = total;
    data['payWithCash'] = payWithCash;
    data['notes'] = notes;
    return data;
  }
}

class OrderItem {
  Restaurant restaurant;
  List<OrderItemIngredient> ingredients;
  String name;
  int quantity;
  String notes;
  String price;

  OrderItem(
      {@required this.restaurant,
      this.ingredients,
      this.name,
      this.quantity,
      this.notes,
      this.price});

  OrderItem.fromJson(Map<String, dynamic> json) {
    if (json['selectedingredients_set'] != null) {
      ingredients = <OrderItemIngredient>[];
      json['selectedingredients_set'].forEach((v) {
        ingredients.add(OrderItemIngredient.fromJson(v));
      });
    }
    name = json['name'];
    quantity = json['quantity'];
    notes = json['notes'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (ingredients != null) {
      data['selectedingredients_set'] =
          ingredients.map((v) => v.toJson()).toList();
    }
    data['name'] = name;
    data['quantity'] = quantity;
    data['notes'] = notes;
    data['price'] = price;
    return data;
  }

  @override
  String toString() {
    return "$name, $quantity, $price, $ingredients";
  }
}

class OrderItemIngredient {
  String name;
  int quantity;
  String price;

  OrderItemIngredient({this.name, this.quantity, this.price});

  OrderItemIngredient.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    quantity = json['quantity'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['quantity'] = quantity;
    data['price'] = price;
    return data;
  }

  @override
  String toString() {
    return "$name x $quantity = $price";
  }
}
