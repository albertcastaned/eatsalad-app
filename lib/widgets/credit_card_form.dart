import 'package:EatSalad/providers/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/auth.dart';
import '../providers/payment_methods.dart';
import '../services/stripe.dart' as stripe;
import '../utils/card_utils.dart';
import '../utils/dialog_utils.dart';

class CustomCreditCardForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const CustomCreditCardForm(
      {Key key,
      this.cardNumber,
      this.expiryDate,
      this.cardHolderName,
      this.cvvCode,
      @required this.onCreditCardModelChange,
      this.themeColor,
      this.textColor = Colors.black,
      this.cursorColor,
      this.formKey})
      : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color cursorColor;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CustomCreditCardForm> {
  GlobalKey<FormState> formKey;

  Future<void> saveCard(BuildContext context) async {
    final loadingDialog =
        buildLoadingDialog(context, 'Agregando nueva tarjeta...');

    try {
      final profile =
          await Provider.of<MyProfile>(context, listen: false).fetch();
      final card = CreditCardModel(
        cardNumber,
        expiryDate,
        cardHolderName,
        cvvCode,
        true,
      );

      final createPaymentMethodResponse = await stripe.createPaymentMethod(
        card: card,
        customerId: profile.stripeCustomerId,
      );
      if (!createPaymentMethodResponse.success) {
        print(createPaymentMethodResponse);
        buildFlashBar(context, Errors.stripeTransactionError);
      } else {
        final paymentMethod =
            PaymentMethod.fromJson(createPaymentMethodResponse.response);

        final attachPaymentMethodResponse =
            await stripe.attachPaymentMethodToCustomer(
          customerId: profile.stripeCustomerId,
          paymentMethodId: paymentMethod.id,
        );

        if (attachPaymentMethodResponse.success) {
          Provider.of<PaymentMethods>(context, listen: false)
              .addPaymentMethod(paymentMethod);
          await showSuccesfulDialog(
            context,
            'Tarjeta aprobada',
          );
          Navigator.pop(context, true);
        } else {
          print(attachPaymentMethodResponse);
          buildFlashBar(context, Errors.stripeTransactionError);
        }
      }
    } catch (error) {
      buildFlashBar(context, Errors.connectionError);
      rethrow;
    } finally {
      loadingDialog.hide();
    }
  }

  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;
  Color themeColor;

  void Function(CreditCardModel) onCreditCardModelChange;
  CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCardModel(
        cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused);
  }

  @override
  void initState() {
    super.initState();
    formKey = widget.formKey ?? GlobalKey<FormState>();

    createCreditCardModel();

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor ?? Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: TextFormField(
                key: Key('number-field'),
                controller: _cardNumberController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Numero de Tarjeta',
                  hintText: 'xxxx xxxx xxxx xxxx',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return Errors.emptyField;
                  }
                  if (!CardUtils.validCreditCard(value)) {
                    return Errors.invalidPaymentMethod;
                  }

                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                key: Key('date-field'),
                controller: _expiryDateController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Fecha de Vencimiento',
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return Errors.emptyField;
                  }
                  return CardUtils.validDate(value);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                key: Key('cvc-field'),
                focusNode: cvvFocusNode,
                controller: _cvvCodeController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'CVV',
                  hintText: 'XXXX',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value.isEmpty) {
                    return Errors.emptyField;
                  }
                  return CardUtils.validCVV(value)
                      ? null
                      : "Este CVV es invalido.";
                },
                onChanged: (text) {
                  setState(() {
                    cvvCode = text;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                key: Key('name-field'),
                controller: _cardHolderNameController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre Completo',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return Errors.emptyField;
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              width: double.infinity,
              child: RaisedButton(
                key: Key('submit'),
                padding: const EdgeInsets.all(14),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text(
                  'Agregar Metodo de Pago',
                ),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    saveCard(context);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
