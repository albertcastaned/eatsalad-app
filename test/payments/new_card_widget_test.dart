import 'dart:async';

import 'package:EatSalad/screens/add_card_screen.dart';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  final client = MockClient();
  when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
      .thenAnswer((_) async => throw TimeoutException("timeout"));
  Widget _makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  final key = GlobalKey<FormState>();

  final nameField = find.byKey(Key("name-field"));

  final numberField = find.byKey(Key("number-field"));
  final dateField = find.byKey(Key("date-field"));
  final cvcField = find.byKey(Key("cvc-field"));

  final submit = find.byKey(Key("submit"), skipOffstage: false);

  final form = find.byKey(key);

  group("Add Payment Method Screen Widget", () {
    testWidgets('has fields', (tester) async {
      await tester.pumpWidget(
        _makeTestable(
          AddCardScreen(
            formKey: key,
          ),
        ),
      );
      expect(nameField, findsOneWidget);
      expect(numberField, findsOneWidget);
      expect(dateField, findsOneWidget);
      expect(cvcField, findsOneWidget);
      expect(submit, findsOneWidget);
      expect(form, findsOneWidget);
    });

    testWidgets("validates form succesfull", (tester) async {
      await tester.pumpWidget(
        _makeTestable(
          AddCardScreen(
            formKey: key,
          ),
        ),
      );
      await tester.pump();
      await tester.enterText(nameField, 'Test');
      await tester.enterText(numberField, '4242424242424242');
      await tester.enterText(dateField, '0299');
      await tester.enterText(cvcField, '123');

      await tester.pump();

      expect(key.currentState.validate(), true);
    });
    testWidgets("validates empty name", (tester) async {
      await tester.pumpWidget(_makeTestable(AddCardScreen(
        formKey: key,
      )));
      await tester.pump();
      await tester.enterText(nameField, '');
      await tester.enterText(numberField, '4242424242424242');
      await tester.enterText(dateField, '0299');
      await tester.enterText(cvcField, '123');
      await tester.pump();
      expect(key.currentState.validate(), false);
    });

    testWidgets("validates empty number field", (tester) async {
      await tester.pumpWidget(_makeTestable(AddCardScreen(
        formKey: key,
      )));
      await tester.pump();
      await tester.enterText(nameField, 'Test');
      await tester.enterText(numberField, '');
      await tester.enterText(dateField, '0299');
      await tester.enterText(cvcField, '123');
      await tester.pump();
      expect(key.currentState.validate(), false);
    });

    testWidgets("validates empty date field", (tester) async {
      await tester.pumpWidget(_makeTestable(AddCardScreen(
        formKey: key,
      )));
      await tester.pump();
      await tester.enterText(nameField, 'Test');
      await tester.enterText(numberField, '424242424242');
      await tester.enterText(dateField, '');
      await tester.enterText(cvcField, '123');
      await tester.pump();
      expect(key.currentState.validate(), false);
    });

    testWidgets("validates empty cvc field", (tester) async {
      await tester.pumpWidget(_makeTestable(AddCardScreen(
        formKey: key,
      )));
      await tester.pump();
      await tester.enterText(nameField, 'Test');
      await tester.enterText(numberField, '424242424242');
      await tester.enterText(dateField, '0299');
      await tester.enterText(cvcField, '');
      await tester.pump();
      expect(key.currentState.validate(), false);
    });
  });

  testWidgets("validates invalid card number", (tester) async {
    await tester.pumpWidget(
      _makeTestable(
        AddCardScreen(
          formKey: key,
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(nameField, 'Test');
    await tester.enterText(numberField, '512535');
    await tester.enterText(dateField, '0299');
    await tester.enterText(cvcField, '123');

    await tester.pump();

    expect(key.currentState.validate(), false);
  });

  testWidgets("validates invalid date", (tester) async {
    await tester.pumpWidget(
      _makeTestable(
        AddCardScreen(
          formKey: key,
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(nameField, 'Test');
    await tester.enterText(numberField, '4242424242424242');
    await tester.enterText(dateField, '0212');
    await tester.enterText(cvcField, '123');

    await tester.pump();

    expect(key.currentState.validate(), false);
  });

  testWidgets("validates invalid cvv", (tester) async {
    await tester.pumpWidget(
      _makeTestable(
        AddCardScreen(
          formKey: key,
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(nameField, 'Test');
    await tester.enterText(numberField, '4242424242424242');
    await tester.enterText(dateField, '0299');
    await tester.enterText(cvcField, '1');

    await tester.pump();

    expect(key.currentState.validate(), false);
  });
}
