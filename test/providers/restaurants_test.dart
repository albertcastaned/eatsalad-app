import 'package:EatSalad/providers/restaurants.dart';

import '../test_utils.dart';

void main() {
  final provider = Restaurants();
  apiBaseTest(
    name: 'Restaurants',
    provider: provider,
    fixtureFileName: 'restaurants.json',
  );
}
