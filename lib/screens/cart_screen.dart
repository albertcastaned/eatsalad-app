import 'dart:async';
import 'dart:io';

import 'package:EatSalad/constants.dart';
import 'package:EatSalad/providers/payments.dart';
import 'package:EatSalad/providers/profile.dart';
import 'package:EatSalad/services/stripe.dart';
import 'package:EatSalad/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/address.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';
import '../providers/payment_methods.dart';
import '../providers/restaurants.dart';
import '../utils/card_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/app_body.dart';
import '../widgets/content_loader.dart';
import '../widgets/value_container.dart';
import 'card_list_screen.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';
  final Restaurant restaurant;
  const CartScreen({Key key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBody(
        isFullScreen: true,
        title: 'Resumen de pedido',
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(),
                    OrderAddress(),
                    Divider(),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Tu pedido',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Consumer<Cart>(
                      builder: (ctx, cart, _) => ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, intex) => Divider(),
                        itemCount: cart.itemsMap[restaurant].length,
                        itemBuilder: (context, index) => CartItem(
                          item: cart.itemsMap[restaurant][index],
                        ),
                      ),
                    ),
                    Divider(),
                    CartTotal(
                      restaurant: restaurant,
                    ),
                    Divider(),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Metodo de Pago',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w400),
                      ),
                    ),
                    SelectedPaymentMethod(),
                    SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: ConfirmOrderButton(restaurant: restaurant)),
          ],
        ));
  }
}

class SelectedPaymentMethod extends StatefulWidget {
  @override
  _SelectedPaymentMethodState createState() => _SelectedPaymentMethodState();
}

class _SelectedPaymentMethodState extends State<SelectedPaymentMethod> {
  Future<void> setFuture() async {
    try {
      final profile =
          await Provider.of<MyProfile>(context, listen: false).fetch();
      await Provider.of<PaymentMethods>(context, listen: false).fetch(
        params: {'stripeId': profile.stripeCustomerId},
      );
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
    return ContentLoader(
      future: setFuture,
      widget: Consumer<PaymentMethods>(
        builder: (ctx, data, child) => Card(
          child: InkWell(
            onTap: () =>
                Navigator.of(context).pushNamed(CardListScreen.routeName),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      data.selectedMethod.isCash
                          ? Icon(
                              Icons.attach_money,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            )
                          : CardUtils.getCardTypeIcon(
                              data.selectedMethod.typeCard,
                            ),
                      SizedBox(
                        width: 40,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.selectedMethod.isCash
                                ? "Efectivo"
                                : "**** ${data.selectedMethod.cardNumber}",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (!data.selectedMethod.isCash)
                            Text(
                              data.selectedMethod.cardHolderName
                                  .capitalizeFirstofEach,
                            ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 20,
                      )
                    ],
                  ),
                  if (!data.selectedMethod.isCash)
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset('assets/stripe.png', width: 125))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu direccion',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
          ),
          ContentLoader(
            future: Provider.of<SelectedAddress>(context, listen: false)
                .fetchSelectedAddress,
            widget: Consumer<SelectedAddress>(
              builder: (ctx, address, _) => Text(
                address.selectedAddress.direction,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ConfirmOrderButton extends StatelessWidget {
  final Restaurant restaurant;
  ConfirmOrderButton({@required this.restaurant});

  @override
  Widget build(BuildContext context) {
    Future<void> createOrder() async {
      var cartProvider = Provider.of<Cart>(context, listen: false);
      final progressDialog = buildLoadingDialog(context, 'Creando pedido...');
      await progressDialog.show();

      var paymentIntent;
      try {
        final total = cartProvider.getTotal(restaurant) +
            double.parse(restaurant.deliveryFee);
        final paymentMethod =
            Provider.of<PaymentMethods>(context, listen: false).selectedMethod;
        final order = await Provider.of<Orders>(context, listen: false).post(
          item: Order(
            restaurant: restaurant,
            orderItems: cartProvider.itemsMap[restaurant],
            subtotal: cartProvider.getTotal(restaurant).toString(),
            total: total.toString(),
            payWithCash: paymentMethod.isCash,
            address: Provider.of<SelectedAddress>(context, listen: false)
                .selectedAddress
                .direction,
          ),
        );

        if (!paymentMethod.isCash) {
          progressDialog.update(message: 'Creando pago...');
          await Provider.of<MyProfile>(context, listen: false).fetch;
          final stripeCustomerId =
              Provider.of<MyProfile>(context, listen: false)
                  .myProfile
                  .stripeCustomerId;
          final response = await createPaymentIntent(
            paymentMethod: paymentMethod.id,
            customer: stripeCustomerId,
            amount: total.toInt() * 100,
          );
          if (!response.success) {
            throw HttpException(
                'Ocurrio un error al procesar el metodo de pago');
          }
          paymentIntent = response.response['id'];

          final payment = Payment(
            order: order,
            paymentIntent: paymentIntent,
          );
          progressDialog.update(message: 'Finalizando pedido...');

          final paymentPostResponse =
              await Provider.of<Payments>(context, listen: false)
                  .post(item: payment);
          print(paymentPostResponse);
        }

        await progressDialog.hide();
        await showSuccesfulDialog(
            context, 'Se ha creado su pedido exitosamente');

        cartProvider.clearCart(restaurant);
        // TODO: Navigate to order detail or orders history

        Navigator.of(context).popUntil((route) => route.isFirst);
      } on HttpException catch (error) {
        print(error);
        await progressDialog.hide();

        buildFlashBar(context, error.message);
      } on TimeoutException catch (error) {
        print(error);
        await progressDialog.hide();

        buildFlashBar(context, Errors.timeout);
      } catch (error) {
        print(error);
        await progressDialog.hide();

        buildFlashBar(context, Errors.connectionError);
      }
    }

    return Consumer<Cart>(
      builder: (ctx, cart, _) {
        final total =
            (cart.getTotal(restaurant) + double.parse(restaurant.deliveryFee))
                .toStringAsFixed(2);
        return RaisedButton(
          padding: EdgeInsets.all(20),
          onPressed: () => cart.getQuantity(restaurant) > 0
              ? showAlertDialog(
                  context: context,
                  title: 'Confirmar pedido',
                  content: 'Desea enviar este pedido?',
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        createOrder();
                      },
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirmar pedido',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              ValueContainer(
                content: "\$$total",
              ),
            ],
          ),
        );
      },
    );
  }
}

class CartTotal extends StatelessWidget {
  final Restaurant restaurant;
  CartTotal({@required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (ctx, cart, _) => Card(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              PriceRow(
                title: "Subtotal",
                value: "\$${cart.getTotal(restaurant).toStringAsFixed(2)}",
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              PriceRow(
                title: "Servicio",
                value: "\$${restaurant.deliveryFee}",
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              PriceRow(
                title: "Total",
                value:
                    // ignore: lines_longer_than_80_chars
                    "\$${(cart.getTotal(restaurant) + double.parse(restaurant.deliveryFee)).toStringAsFixed(2)}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle textStyle;

  PriceRow({
    @required this.title,
    @required this.value,
    this.textStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textStyle,
          ),
          Text(
            value,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final OrderItem item;
  CartItem({@required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.name.toString()} x ${item.quantity.toString()}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    if (item.ingredients != null)
                      for (OrderItemIngredient ingredient in item.ingredients)
                        Text(
                          ingredient.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                    Text(
                      item.notes,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Row(
                children: [
                  ValueContainer(
                    content: "\$${item.price}",
                  ),
                  IconButton(
                    color: Theme.of(context).errorColor,
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false).remove(
                          Provider.of<Restaurants>(context, listen: false)
                              .selectedRestaurant,
                          item);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
