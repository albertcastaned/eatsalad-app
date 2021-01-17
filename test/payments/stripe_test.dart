import 'dart:async';
import 'dart:convert';

import 'package:EatSalad/services/stripe.dart' as stripe;
import 'package:flutter_credit_card/credit_card_model.dart';

import 'package:mockito/mockito.dart';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  final testCard =
      CreditCardModel("4242424242424242", "2/25", "Test Guy", '123', true);
  final headers = <String, String>{
    'Authorization': 'Bearer test',
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  group('Stripe add new payment method', () {
    test('returns successful', () async {
      final client = MockClient();

      when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"id": "Test"}', 200));

      final response = await stripe.createPaymentMethod(
        card: testCard,
        customerId: '1',
        stripeHeaders: headers,
        client: client,
      );
      expect(response.success, true);
      expect(response.response,
          jsonDecode(http.Response('{"id": "Test"}', 200).body));

      verify(client.post(any,
              body: anyNamed('body'), headers: anyNamed('headers')))
          .called(1);
    });

    test('returns unsuccessful', () async {
      final client = MockClient();

      when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"id": "Test"}', 400));

      final response = await stripe.createPaymentMethod(
        card: testCard,
        customerId: '1',
        stripeHeaders: headers,
        client: client,
      );
      expect(response.success, false);
      expect(response.response, isNull);

      verify(client.post(any,
              body: anyNamed('body'), headers: anyNamed('headers')))
          .called(1);
    });
    test('returns timeout', () async {
      final client = MockClient();

      when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => throw TimeoutException('error'));

      expect(
        stripe.createPaymentMethod(
          card: testCard,
          customerId: '1',
          stripeHeaders: headers,
          client: client,
        ),
        throwsA(
          isA<TimeoutException>(),
        ),
      );
    });
  });

  group('Stripe add payment method to customer', () {
    test(
      'returns successful',
      () async {
        final client = MockClient();

        when(
          client.post(any,
              body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"id": "Test"}', 200));

        final response = await stripe.attachPaymentMethodToCustomer(
          customerId: '1',
          paymentMethodId: '1',
          stripeHeaders: headers,
          client: client,
        );
        expect(response.success, true);
        expect(response.response,
            jsonDecode(http.Response('{"id": "Test"}', 200).body));

        verify(client.post(any,
                body: anyNamed('body'), headers: anyNamed('headers')))
            .called(1);
      },
    );

    test('returns unsuccessful', () async {
      final client = MockClient();

      when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"id": "Test"}', 400));

      final response = await stripe.attachPaymentMethodToCustomer(
        customerId: '1',
        paymentMethodId: '1',
        stripeHeaders: headers,
        client: client,
      );
      expect(response.success, false);
      expect(response.response, isNull);

      verify(client.post(any,
              body: anyNamed('body'), headers: anyNamed('headers')))
          .called(1);
    });
    test('returns timeout', () async {
      final client = MockClient();

      when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => throw TimeoutException('error'));

      expect(
        stripe.attachPaymentMethodToCustomer(
          customerId: '1',
          paymentMethodId: '1',
          stripeHeaders: headers,
          client: client,
        ),
        throwsA(
          isA<TimeoutException>(),
        ),
      );
    });
  });
}
