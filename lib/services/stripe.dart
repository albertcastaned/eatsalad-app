import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success, this.response});
  Map<String, dynamic> response;
}

final String apiBase = 'https://api.stripe.com/v1';
final String paymentApiUrl = '$apiBase/payment_intents';
final String paymentApiUrlCards = '$apiBase/payment_methods';
final String paymentMethodApiUrl = '$apiBase/payment_methods';

final String secret = stripeSecretKey;
final Map<String, String> headers = {
  'Authorization': 'Bearer $secret',
  'Content-Type': 'application/x-www-form-urlencoded',
};

Future<List> getPaymentMethods(String customerId) async {
  try {
    final body = <String, String>{
      'customer': customerId,
      'type': 'card',
    };
    final url = Uri.https('api.stripe.com', '/v1/payment_methods', body);
    final response = await http.get(url, headers: headers);

    return jsonDecode(response.body)['data'] as List;
  } catch (error) {
    rethrow;
  }
}

Future<StripeTransactionResponse> createPaymentMethod(
    {@required CreditCardModel card,
    @required String customerId,
    Map<String, String> stripeHeaders,
    http.Client client}) async {
  try {
    final mClient = (client != null) ? client : http.Client();

    // Create payment method
    final createPaymentMethodUrl = '$apiBase/payment_methods';

    final createBody = cardToJson(card);

    final response = await mClient
        .post(
          createPaymentMethodUrl,
          body: createBody,
          headers: (stripeHeaders == null) ? headers : stripeHeaders,
        )
        .timeout(Duration(seconds: timeoutSeconds));
    final data = json.decode(response.body);

    if (response.statusCode >= 400) {
      return StripeTransactionResponse(
          message: 'Transaction failed: $data', success: false);
    }

    return StripeTransactionResponse(
      message: 'Transaction successful',
      success: true,
      response: data,
    );
  } on TimeoutException catch (error) {
    print(error);
    rethrow;
  } catch (error) {
    print(error);
    return StripeTransactionResponse(
      message: 'Transaction failed: ${error.toString}',
      success: false,
    );
  }
}

Future<StripeTransactionResponse> attachPaymentMethodToCustomer(
    {@required String customerId,
    @required String paymentMethodId,
    Map<String, String> stripeHeaders,
    http.Client client}) async {
  final mClient = (client != null) ? client : http.Client();

  try {
    /// Attack to customer
    final paymentCustomerUrl =
        '$apiBase/payment_methods/$paymentMethodId/attach';

    final body = customerToJson(customerId: customerId);

    final response = await mClient
        .post(
          paymentCustomerUrl,
          body: body,
          headers: (stripeHeaders == null) ? headers : stripeHeaders,
        )
        .timeout(Duration(seconds: timeoutSeconds));
    final data = json.decode(response.body);

    if (response.statusCode >= 400) {
      return StripeTransactionResponse(
          message: 'Transaction failed: $data', success: false);
    }
    return StripeTransactionResponse(
      message: 'Transaction successful',
      success: true,
      response: data,
    );
  } on TimeoutException catch (error) {
    print(error);
    rethrow;
  } catch (error) {
    print(error);
    return StripeTransactionResponse(
      message: 'Transaction failed: ${error.toString}',
      success: false,
    );
  }
}

Map<String, dynamic> customerToJson({String customerId}) {
  return {
    'customer': customerId,
  };
}

Map<String, dynamic> cardToJson(CreditCardModel card) {
  final expMonth = card.expiryDate.split("/")[0];
  final expYear = card.expiryDate.split("/")[1];
  return {
    'type': 'card',
    'card[number]': card.cardNumber,
    'card[exp_month]': expMonth,
    'card[exp_year]': expYear,
    'card[cvc]': card.cvvCode,
    'billing_details[name]': card.cardHolderName,
  };
}
