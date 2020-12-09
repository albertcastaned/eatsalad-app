import 'dart:convert';
import 'package:EatSalad/providers/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../utils.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String paymentApiUrlCards = '${StripeService.apiBase}/payment_methods';
  static String paymentMethodApiUrl =
      '${StripeService.apiBase}/payment_methods';

  static String secret = Constants.stripeSecretKey;
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

/*
  static Future<StripeTransactionResponse> payViaExistingCard({
    BuildContext context,
    int reservationId,
    String paymentMethodId,
  }) async {
    ProgressDialog dialog = buildLoadingDialog(context, 'Generando Pago...');
    try {
      await dialog.show();
      final responsePaymentApi =
          await Provider.of<Payments>(context, listen: false)
              .requestPaymentIntent(context, reservationId);
      //secret
      final secret = responsePaymentApi['client_secret'];
      //confirm mandando id
      final response = await confirmPaymentIntent(secret, paymentMethodId);

      if (response.success == true) {
        return new StripeTransactionResponse(
            message: response.message, success: true);
      } else {
        return new StripeTransactionResponse(
            message: response.message, success: false);
      }
    } catch (error) {
      print(error);
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${error.toString}', success: false);
    } finally {
      dialog.hide();
    }
  }

*/
  static Future<StripeTransactionResponse> addNewCard(
      {@required BuildContext context,
      @required CreditCardModel card,
      @required String customerId}) async {
    ProgressDialog dialog =
        buildLoadingDialog(context, 'Agregando nueva tarjeta...');

    try {
      await dialog.show();

      // Create payment method
      final createPaymentMethodUrl = '${StripeService.apiBase}/payment_methods';

      String expMonth = card.expiryDate.split("/")[0];
      String expYear = card.expiryDate.split("/")[1];

      Map<String, Object> createBody = {
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
            headers: StripeService.headers,
          )
          .timeout(Duration(seconds: Constants.timeoutSeconds));

      final createData = json.decode(createResponse.body);
      if (createResponse.statusCode >= 400)
        return new StripeTransactionResponse(
            message: 'Transaction failed: $createData', success: false);

      final paymenthMethodId = createData['id'];

      /// Attack to customer
      final paymentCustomerUrl =
          '${StripeService.apiBase}/payment_methods/$paymenthMethodId/attach';

      Map<String, dynamic> body = {
        'customer': customerId,
      };

      final response = await http
          .post(
            paymentCustomerUrl,
            body: body,
            headers: StripeService.headers,
          )
          .timeout(Duration(seconds: Constants.timeoutSeconds));
      final data = json.decode(response.body);

      if (response.statusCode >= 400) {
        return new StripeTransactionResponse(
            message: 'Transaction failed: $data', success: false);
      } else {
        Provider.of<PaymentMethods>(context, listen: false).addPaymentMethod(
          new PaymentMethod(
            id: createData['id'],
            cardNumber: createData['card']['last4'],
            expiryDate: createData['card']['exp_month'].toString() +
                '/' +
                createData['card']['exp_year'].toString(),
            cardHolderName: createData['billing_details']['name'],
            typeCard: createData['card']['brand'],
          ),
        );
      }

      return new StripeTransactionResponse(
          message: 'Transaction successful', success: true);
    } catch (error) {
      print(error);
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${error.toString}', success: false);
    } finally {
      dialog.hide();
    }
  }

  static Future<List> getPaymentMethods(String customerId) async {
    try {
      Map<String, String> body = {
        'customer': customerId,
        'type': 'card',
      };
      final url = Uri.https('api.stripe.com', '/v1/payment_methods', body);
      final response = await http.get(url, headers: StripeService.headers);

      return jsonDecode(response.body)['data'] as List;
    } catch (error) {
      throw error;
    }
  }

/*
  static Future<StripeTransactionResponse> confirmPaymentIntent(
      String clientSecret, String paymentMethodId) async {
    try {
      await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: clientSecret,
          paymentMethodId: paymentMethodId,
        ),
      );
      // mandarle esto a api
      // response.paymentIntentId;

      return StripeTransactionResponse(
        message: 'Pago realizado exitosamente.',
        success: true,
      );
    } catch (error) {
      print(error);

      return StripeTransactionResponse(
        message: 'Error al procesar el pago.',
        success: false,
      );
    }
  }
  */

}
