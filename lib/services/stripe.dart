import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/payment_methods.dart';
import '../utils.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
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

Future<StripeTransactionResponse> addNewCard(
    {@required BuildContext context,
    @required CreditCardModel card,
    @required String customerId}) async {
  final dialog = buildLoadingDialog(context, 'Agregando nueva tarjeta...');

  try {
    await dialog.show();

    // Create payment method
    final createPaymentMethodUrl = '$apiBase/payment_methods';

    final expMonth = card.expiryDate.split("/")[0];
    final expYear = card.expiryDate.split("/")[1];

    final createBody = {
      'type': 'card',
      'card[number]': card.cardNumber,
      'card[exp_month]': expMonth,
      'card[exp_year]': expYear,
      'card[cvc]': card.cvvCode,
      'billing_details[name]': card.cardHolderName,
    };

    final createResponse = await http
        .post(
          createPaymentMethodUrl,
          body: createBody,
          headers: headers,
        )
        .timeout(Duration(seconds: timeoutSeconds));

    final createData = json.decode(createResponse.body);
    if (createResponse.statusCode >= 400) {
      return StripeTransactionResponse(
          message: 'Transaction failed: $createData', success: false);
    }

    final paymenthMethodId = createData['id'];

    /// Attack to customer
    final paymentCustomerUrl =
        '$apiBase/payment_methods/$paymenthMethodId/attach';

    final body = {
      'customer': customerId,
    };

    final response = await http
        .post(
          paymentCustomerUrl,
          body: body,
          headers: headers,
        )
        .timeout(Duration(seconds: timeoutSeconds));
    final data = json.decode(response.body);

    if (response.statusCode >= 400) {
      return StripeTransactionResponse(
          message: 'Transaction failed: $data', success: false);
    } else {
      Provider.of<PaymentMethods>(context, listen: false).addPaymentMethod(
        PaymentMethod(
          id: createData['id'],
          cardNumber: createData['card']['last4'],
          expiryDate:
              '${createData['card']['exp_month']}/${createData['card']['exp_year']}',
          cardHolderName: createData['billing_details']['name'],
          typeCard: createData['card']['brand'],
        ),
      );
    }

    return StripeTransactionResponse(
        message: 'Transaction successful', success: true);
  } catch (error) {
    print(error);
    return StripeTransactionResponse(
        message: 'Transaction failed: ${error.toString}', success: false);
  } finally {
    dialog.hide();
  }
}
