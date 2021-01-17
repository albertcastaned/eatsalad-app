import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../exceptions/invalid_json_exception.dart';

import '../utils/api_utils.dart';
import 'api_provider.dart';
import 'base_model.dart';
import 'restaurants.dart';

class Orders extends ApiProvider<Order> {
  Orders([List items]) : super(items);

  @override
  Future<bool> fetch({
    http.Client client,
    Map<String, dynamic> params,
    String token,
  }) async {
    //TODO: Fetch my orders
    if (token == null) {
      token = await FirebaseAuth.instance.currentUser.getIdToken();
    }
    throw UnimplementedError();
  }

  @override
  Future post({
    item,
    http.Client client,
    String token,
  }) async {
    try {
      if (token == null) {
        token = await FirebaseAuth.instance.currentUser.getIdToken();
      }
      final url = "$server/orders/";
      final body = item.toJson();

      await ApiHandler.request(
        method: HTTP_METHOD.post,
        body: body,
        token: token,
        url: url,
        client: client,
      );
    } on TimeoutException {
      rethrow;
    } on HttpException {
      rethrow;
    } on InvalidJsonException {
      rethrow;
    }
  }
}

class Order implements BaseModel {
  int id;
  String status;
  List<OrderItem> orderItems;
  Restaurant restaurant;
  DateTime deliveryDatetime;
  String orderDatetime;
  String subtotal;
  String total;
  bool payWithCash;
  String notes;

  Order(
      {this.id,
      this.status,
      this.orderItems,
      this.restaurant,
      this.deliveryDatetime,
      this.orderDatetime,
      this.subtotal,
      this.total,
      this.payWithCash,
      this.notes});

  Order.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);
    id = json['id'];
    status = json['status'];
    if (json['orderitem_set'] != null) {
      orderItems = <OrderItem>[];
      json['orderitem_set'].forEach((v) {
        orderItems.add(OrderItem.fromJson(v));
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

    data['restaurant_input'] = restaurant.id;
    data['total'] = total;
    data['subtotal'] = subtotal;
    data['payWithCash'] = payWithCash;
    data['orderitem_set'] = [
      for (OrderItem orderItem in orderItems) orderItem.toJson()
    ];
    return data;
  }

  @override
  List<String> requiredKeys = [
    'status',
    'orderitem_set',
    'restaurant',
    'delivery_datetime',
    'order_datetime',
    'subtotal',
    'total',
    'payWithCash',
    'notes'
  ];
}

class OrderItem implements BaseModel {
  Restaurant restaurant;
  List<OrderItemIngredient> ingredients;
  String name;
  int quantity;
  String notes;
  String price;

  OrderItem({
    @required this.restaurant,
    this.ingredients,
    this.name,
    this.quantity,
    this.notes,
    this.price,
  });

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

  @override
  List<String> requiredKeys = [
    'name',
    'quantity',
    'notes',
    'price',
  ];
}

class OrderItemIngredient implements BaseModel {
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

  @override
  List<String> requiredKeys = [
    'name',
    'quantity',
    'price',
  ];
}
