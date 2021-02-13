import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:EatSalad/providers/orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../exceptions/invalid_json_exception.dart';

import '../utils/api_utils.dart';
import 'api_provider.dart';
import 'base_model.dart';

class Payments extends ApiProvider<Payment> {
  Payments([List items]) : super(items);

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
  Future<dynamic> post({
    item,
    http.Client client,
    String token,
  }) async {
    try {
      if (token == null) {
        token = await FirebaseAuth.instance.currentUser.getIdToken();
      }
      final url = "$server/payments/";
      final body = item.toJson();

      final response = await ApiHandler.request(
        method: HTTP_METHOD.post,
        body: body,
        token: token,
        url: url,
        client: client,
      );
      return response;
    } on TimeoutException {
      rethrow;
    } on HttpException catch (error) {
      throw HttpException(
          jsonDecode(error.message)['response'] ?? Errors.unknownError);
    } on InvalidJsonException {
      rethrow;
    }
  }
}

class Payment implements BaseModel {
  String paymentIntent;
  Order order;
  bool isSuccesful;

  Payment({
    this.paymentIntent,
    this.order,
    this.isSuccesful,
  });

  Payment.fromJson(Map<String, dynamic> json) {
    paymentIntent = json['stripe_payment_intent'];
    order = Order.fromJson(json['order']);
    isSuccesful = json['is_succesful'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['stripe_payment_intent'] = paymentIntent;
    data['order'] = order.id;
    return data;
  }

  @override
  List<String> requiredKeys = [
    'stripe_payment_intent',
    'order',
    'is_succesful',
  ];
}
