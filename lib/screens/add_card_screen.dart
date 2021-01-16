import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../widgets/app_body.dart';
import '../widgets/credit_card_form.dart';

class AddCardScreen extends StatefulWidget {
  static const routeName = "/payment/new";
  final GlobalKey<FormState> formKey;
  AddCardScreen({this.formKey});
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  GlobalKey<FormState> formKey;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = 'NOMBRE APELLIDO';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  void initState() {
    formKey = widget.formKey ?? GlobalKey<FormState>();

    cardNumber = '4242 4242 4242 4242';
    expiryDate = '02/22';
    cvvCode = '123';
    cardHolderName = 'Alberto Test';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      isFullScreen: true,
      title: 'Nuevo metodo de pago',
      child: SingleChildScrollView(
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
            ),
            CustomCreditCardForm(
              onCreditCardModelChange: onCreditCardModelChange,
              formKey: formKey,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset('assets/stripe.png', width: 130),
            )
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
