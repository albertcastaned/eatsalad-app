import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/stripe.dart';
import 'package:flutter/material.dart';

class PaymentMethods extends ChangeNotifier {
  PaymentMethod selectedMethod;
  List<PaymentMethod> paymentMethods;
  Future<void> fetchPaymentMethods(String stripeId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final selectedPaymentMethod = prefs.getString("selected_payment_method");

      List<PaymentMethod> fetchedCards = new List<PaymentMethod>();

      PaymentMethod cashPaymentMethod = new PaymentMethod(
        typeCard: 'cash',
        cardHolderName: '',
        isCash: true,
        cardNumber: '-1',
        id: "-1",
        expiryDate: "-1",
      );
      fetchedCards.add(cashPaymentMethod);

      final paymentMethodsData =
          await StripeService.getPaymentMethods(stripeId);

      // No payment method card set
      if (paymentMethodsData.isEmpty) {
        cashPaymentMethod.selected = true;
        selectedMethod = cashPaymentMethod;
      } else if (selectedPaymentMethod != null &&
          cashPaymentMethod.id == selectedPaymentMethod) {
        cashPaymentMethod.selected = true;
        selectedMethod = cashPaymentMethod;
      }

      paymentMethodsData.forEach((card) {
        String month = card['card']['exp_month'].toString();
        String year = card['card']['exp_year'].toString();
        String expirydate = month + '/' + year;

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
      });

      paymentMethods = fetchedCards;
    } catch (error) {
      throw error;
    }
  }

  void addPaymentMethod(PaymentMethod method) {
    paymentMethods.add(method);
    notifyListeners();
  }

  Future<void> setSelected(PaymentMethod newMethod) async {
    for (PaymentMethod method in paymentMethods) {
      method.selected = method == newMethod;
      if (method == newMethod) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("selected_payment_method", newMethod.id);
        method.selected = true;
        selectedMethod = method;
      } else {
        method.selected = false;
      }
    }
    notifyListeners();
  }
}

class PaymentMethod {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final bool newCard;
  final String typeCard;
  bool selected;
  final bool isCash;

  PaymentMethod(
      {@required this.id,
      @required this.cardNumber,
      @required this.expiryDate,
      @required this.cardHolderName,
      this.newCard = false,
      this.typeCard,
      this.selected = false,
      this.isCash = false});

  @override
  String toString() {
    return isCash
        ? "Cash"
        : "Card Number: $cardNumber, Card Holder Name: $cardHolderName";
  }

  @override
  bool operator ==(covariant PaymentMethod other) {
    return this.cardNumber == other.cardNumber;
  }

  @override
  int get hashCode => int.parse(cardNumber);
}
