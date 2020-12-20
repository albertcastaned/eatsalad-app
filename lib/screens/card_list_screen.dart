import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/payment_methods.dart';
import '../utils/card_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/app_body.dart';
import '../widgets/app_title.dart';
import '../widgets/content_loader.dart';
import 'add_card_screen.dart';

class CardListScreen extends StatefulWidget {
  static const routeName = "/cards";
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  Future<void> setFuture() async {
    try {
      final profile =
          await Provider.of<Auth>(context, listen: false).fetchMyProfile();
      await Provider.of<PaymentMethods>(context, listen: false)
          .fetchPaymentMethods(profile.stripeCustomerId);
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    setFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      isFullScreen: true,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTitle(
                text: 'Metodos de pago',
              ),
              ContentLoader(
                future: setFuture(),
                widget: Consumer<PaymentMethods>(
                  builder: (ctx, data, child) => Flexible(
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, intex) => Divider(),
                      itemCount: data.paymentMethods.length,
                      itemBuilder: (context, index) =>
                          !data.paymentMethods[index].isCash
                              ? PaymentTile(
                                  paymentMethod: data.paymentMethods[index],
                                )
                              : CashPaymentTile(
                                  cashPaymentMethod: data.paymentMethods[index],
                                ),
                    ),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                width: double.infinity,
                child: RaisedButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textColor: Colors.white,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AddCardScreen.routeName),
                  child: Text(
                    'Agregar nuevo metodo de pago',
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentTile extends StatefulWidget {
  final PaymentMethod paymentMethod;

  PaymentTile({@required this.paymentMethod});

  @override
  _PaymentTileState createState() => _PaymentTileState();
}

class CashPaymentTile extends StatefulWidget {
  final PaymentMethod cashPaymentMethod;
  CashPaymentTile({@required this.cashPaymentMethod});

  @override
  _CashPaymentTileState createState() => _CashPaymentTileState();
}

class _CashPaymentTileState extends State<CashPaymentTile> {
  Future<void> selectCard() async {
    await Provider.of<PaymentMethods>(context, listen: false)
        .setSelected(widget.cashPaymentMethod);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: InkWell(
        onTap: selectCard,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(
                width: 40,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Efectivo",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Spacer(),
              if (widget.cashPaymentMethod.selected)
                Flexible(
                  child: Container(
                    child: Text('Seleccionado'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTileState extends State<PaymentTile> {
  bool isAmex = false;

  Future<void> selectCard() async {
    await Provider.of<PaymentMethods>(context, listen: false)
        .setSelected(widget.paymentMethod);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: InkWell(
        onTap: selectCard,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [
              CardUtils.getCardTypeIcon(widget.paymentMethod.typeCard),
              SizedBox(
                width: 30,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "**** ${widget.paymentMethod.cardNumber}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.paymentMethod.cardHolderName.capitalizeFirstofEach,
                  )
                ],
              ),
              SizedBox(
                width: 30,
              ),
              if (widget.paymentMethod.selected)
                Flexible(
                  child: Container(
                    child: Text('Seleccionado'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
