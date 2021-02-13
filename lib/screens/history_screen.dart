import 'package:EatSalad/screens/items_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../widgets/app_card.dart';
import '../widgets/content_loader.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: ContentLoader(
              allowRefresh: true,
              future: Provider.of<Orders>(context, listen: false).fetch,
              widget: Consumer<Orders>(
                builder: (ctx, data, child) => ListView.separated(
                  separatorBuilder: (context, intex) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  itemCount: data.items.length,
                  itemBuilder: (context, index) => OrderCard(
                    order: data.items[index],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  final DateFormat outputFormat = DateFormat("MM/dd/yyyy hh:mm a");
  final double radius = 15;
  OrderCard({this.order});
  @override
  Widget build(BuildContext context) {
    final orderDate =
        outputFormat.format(inputFormat.parse(order.orderDatetime));
    final deliveryDate = order.deliveryDatetime == null
        ? null
        : outputFormat.format(inputFormat.parse(order.deliveryDatetime));
    return AppCard(
      child: InkWell(
        onTap: () => print("Test"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius)),
                  child: Image.network(
                    order.restaurant.image,
                    height: 85,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Image.asset(
                      'assets/image_404.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 5,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(radius)),
                    child: Text(
                      order.restaurant.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HistoryCardInfo(
                    leading: Text(
                      "Fecha de pedido:",
                    ),
                    trailing: Text(
                      " $orderDate",
                    ),
                  ),
                  Divider(),
                  if (deliveryDate != null)
                    HistoryCardInfo(
                      leading: Text(
                        "\Fecha de entrega: ",
                      ),
                      trailing: Text(
                        "$deliveryDate",
                      ),
                    ),
                  if (deliveryDate != null) Divider(),
                  HistoryCardInfo(
                    leading: Text(
                      "Estado de pedido: ",
                    ),
                    trailing: OrderStatus(status: order.status),
                  ),
                  Divider(),
                  HistoryCardInfo(
                    leading: Text(
                      "Total: ",
                    ),
                    trailing: ValueContainer(
                      content: "\$${order.total}",
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HistoryCardInfo extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  HistoryCardInfo({this.leading, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (leading != null) leading,
          if (trailing != null) trailing,
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}

class OrderStatus extends StatelessWidget {
  final String status;
  OrderStatus({this.status});
  @override
  Widget build(BuildContext context) {
    final statusColor = {
      'Nuevo': Color(0xff49a638),
      'En proceso': Color(0xff58e873),
      'En camino': Color(0xff27e84c),
      'Entregado': Colors.green,
      'Cancelado': Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: statusColor[status],
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
