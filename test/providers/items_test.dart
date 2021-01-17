import 'package:EatSalad/providers/items.dart';

import '../test_utils.dart';

void main() {
  final provider = CategoriesProvider();
  apiBaseTest(
      name: 'Items',
      provider: provider,
      fixtureFileName: 'items.json',
      params: {'restaurant': 1});
}
