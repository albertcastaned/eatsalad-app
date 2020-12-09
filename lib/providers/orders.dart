import 'package:firebase_auth/firebase_auth.dart';

import 'restaurants.dart';
import 'package:flutter/foundation.dart';
import '../utils.dart';
import '../constants.dart';

class Orders extends ChangeNotifier {
  Future<void> createOrder({
    @required Restaurant restaurant,
    @required List<OrderItem> orderItems,
    @required double subtotal,
    @required double total,
    @required bool payWithCash,
  }) async {
    try {
      final String apiUrl = "${Constants.server}/orders/";
      String token = await FirebaseAuth.instance.currentUser.getIdToken();

      Map<String, dynamic> body = {
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
      throw error;
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
      orders = new List<OrderItem>();
      json['orderitem_set'].forEach((v) {
        orders.add(new OrderItem.fromJson(v));
      });
    }
    restaurant = json['restaurant'] != null
        ? new Restaurant.fromJson(json['restaurant'])
        : null;
    deliveryDatetime = json['delivery_datetime'];
    orderDatetime = json['order_datetime'];
    subtotal = json['subtotal'];
    total = json['total'];
    payWithCash = json['payWithCash'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    if (this.orders != null) {
      data['orderitem_set'] = this.orders.map((v) => v.toJson()).toList();
    }
    if (this.restaurant != null) {
      data['restaurant'] = this.restaurant.toJson();
    }
    data['delivery_datetime'] = this.deliveryDatetime;
    data['order_datetime'] = this.orderDatetime;
    data['subtotal'] = this.subtotal;
    data['total'] = this.total;
    data['payWithCash'] = this.payWithCash;
    data['notes'] = this.notes;
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
      ingredients = new List<OrderItemIngredient>();
      json['selectedingredients_set'].forEach((v) {
        ingredients.add(new OrderItemIngredient.fromJson(v));
      });
    }
    name = json['name'];
    quantity = json['quantity'];
    notes = json['notes'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ingredients != null) {
      data['selectedingredients_set'] =
          this.ingredients.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['notes'] = this.notes;
    data['price'] = this.price;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    return data;
  }

  @override
  String toString() {
    return "$name x $quantity = $price";
  }
}
