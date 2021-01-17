import 'package:EatSalad/providers/orders.dart';
import 'package:EatSalad/providers/restaurants.dart';

import '../test_utils.dart';

void main() {
  final provider = Orders();
  final order = Order(
    restaurant: Restaurant(id: 1),
    total: '1000',
    subtotal: '500',
    payWithCash: true,
    orderItems: [],
  );
  apiPostBaseTest(
    name: 'Order create',
    provider: provider,
    item: order,
  );
}
