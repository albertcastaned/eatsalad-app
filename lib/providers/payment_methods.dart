import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/invalid_json_exception.dart';
import '../services/stripe.dart' as stripe;
import '../utils/api_utils.dart';
import 'base_model.dart';

class PaymentMethods extends ChangeNotifier {
  PaymentMethod selectedMethod;
  List<PaymentMethod> items;
  PaymentMethods([List items]);

  void addPaymentMethod(PaymentMethod method) {
    items.add(method);
    notifyListeners();
  }

  Future<void> setSelected(PaymentMethod newMethod) async {
    for (var method in items) {
      method.selected = method == newMethod;
      if (method == newMethod) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("selected_payment_method", newMethod.id);
        method.selected = true;
        selectedMethod = method;
      } else {
        method.selected = false;
      }
    }
    notifyListeners();
  }

  Future<bool> fetch({http.Client client, Map<String, dynamic> params}) async {
    try {
      if (params['stripeId'] == null) {
        print("Stripe id not found in params.");
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      final selectedPaymentMethod = prefs.getString("selected_payment_method");

      final fetchedCards = <PaymentMethod>[];

      final cashPaymentMethod = PaymentMethod(
        typeCard: 'cash',
        isCash: true,
      );
      fetchedCards.add(cashPaymentMethod);

      final paymentMethodsData =
          await stripe.getPaymentMethods(params['stripeId']);

      // No payment method card set
      if (paymentMethodsData.isEmpty) {
        cashPaymentMethod.selected = true;
        selectedMethod = cashPaymentMethod;
      } else if (selectedPaymentMethod != null &&
          cashPaymentMethod.id == selectedPaymentMethod) {
        cashPaymentMethod.selected = true;
        selectedMethod = cashPaymentMethod;
      }
      for (var card in paymentMethodsData) {
        final month = card['card']['exp_month'].toString();
        final year = card['card']['exp_year'].toString();
        final expirydate = '$month/$year';

        final newCard = PaymentMethod(
          cardNumber: card['card']['last4'],
          expiryDate: expirydate,
          cardHolderName: card['billing_details']['name'],
          typeCard: card['card']['brand'],
          id: card['id'],
        );
        if (newCard.id == selectedPaymentMethod) {
          newCard.selected = true;
          selectedMethod = newCard;
        }

        if (!fetchedCards.contains(newCard)) fetchedCards.add(newCard);
      }

      if (selectedMethod == null) {
        selectedMethod = cashPaymentMethod;
      }

      items = fetchedCards;
      return true;
    } on TimeoutException catch (error) {
      print(error);
      rethrow;
    } on HttpException catch (error) {
      print(error);
      rethrow;
    } on InvalidJsonException catch (error) {
      print(error);
      rethrow;
    }
  }

  Future post({item, http.Client client}) {
    throw UnimplementedError();
  }
}

class PaymentMethod implements BaseModel {
  String id;
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  bool newCard;
  String typeCard;
  bool selected;
  bool isCash;

  PaymentMethod({
    this.id,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.newCard = false,
    this.typeCard,
    this.selected = false,
    this.isCash = false,
  });

  @override
  String toString() {
    return isCash
        ? "Cash"
        : "Card Number: $cardNumber, Card Holder Name: $cardHolderName";
  }

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);
    id = json['id'];
    cardNumber = json['card']['last4'];
    expiryDate = '${json['card']['exp_month']}/${json['card']['exp_year']}';
    cardHolderName = json['billing_details']['name'];
    typeCard = json['card']['brand'];
  }

  @override
  List<String> requiredKeys = [
    'id',
    'card',
    'billing_details',
  ];
}
