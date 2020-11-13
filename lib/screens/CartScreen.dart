import 'package:EatSalad/widgets/app_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_body.dart';
import '../providers/restaurants.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';
  final Restaurant restaurant;
  const CartScreen({Key key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBody(
        isFullScreen: true,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: AppTitle(text: restaurant.name),
                    ),
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
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) => CartItem(
                          item: cart.items[index],
                        ),
                      ),
                    ),
                    Divider(),
                    CartTotal(
                      restaurant: restaurant,
                    ),
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

class ConfirmOrderButton extends StatelessWidget {
  final Restaurant restaurant;
  ConfirmOrderButton({@required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (ctx, cart, _) => RaisedButton(
        padding: EdgeInsets.all(20),
        onPressed: cart.getQuantity() > 0
            ? () {
                //TODO: Confirm purchase
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confirmar pedido',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${(cart.getTotal() + double.parse(restaurant.deliveryFee)).toStringAsFixed(2)}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
                value: "\$${cart.getTotal().toStringAsFixed(2)}",
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
                    "\$${(cart.getTotal() + double.parse(restaurant.deliveryFee)).toStringAsFixed(2)}",
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
                  Text(
                    "\$${item.price}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    color: Theme.of(context).errorColor,
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false).remove(item);
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
