import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/items.dart';
import '../providers/restaurants.dart';
import '../widgets/app_body.dart';
import '../widgets/content_loader.dart';
import 'cart_screen.dart';
import 'item_config_screen.dart';

class ItemsScreen extends StatefulWidget {
  static const routeName = '/items';
  final Restaurant restaurant;

  const ItemsScreen({Key key, this.restaurant}) : super(key: key);

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  Future<void> _future;

  @override
  void initState() {
    assert(widget.restaurant != null);

    _future = Provider.of<CategoriesProvider>(context, listen: false).fetch(
      params: {'restaurant': widget.restaurant.id},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      isFullScreen: true,
      title: "Articulos",
      child: Container(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ContentLoader(
                    future: _future,
                    widget: Consumer<CategoriesProvider>(
                      builder: (ctx, categoryData, child) => ListView.separated(
                        separatorBuilder: (context, intex) => Divider(),
                        itemCount: categoryData.items.length,
                        itemBuilder: (context, index) => CategorySection(
                            category: categoryData.items[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: OrderCartPreview(restaurant: widget.restaurant),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final Category category;

  CategorySection({@required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            category.name,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, intex) => Divider(),
            itemCount: category.items.length,
            itemBuilder: (context, index) =>
                ItemSection(item: category.items[index]),
          ),
        ],
      ),
    );
  }
}

class ItemSection extends StatelessWidget {
  final Item item;

  ItemSection({@required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ItemSetup(item: item);
            },
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: item.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  //TODO: Add default image
                  : null,
            ),
            SizedBox(
              width: 40,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text("\$${item.price}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCartPreview extends StatefulWidget {
  final Restaurant restaurant;
  OrderCartPreview({@required this.restaurant});

  @override
  _OrderCartPreviewState createState() => _OrderCartPreviewState();
}

class _OrderCartPreviewState extends State<OrderCartPreview> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (ctx, cart, _) => RaisedButton(
        padding: EdgeInsets.all(20),
        onPressed: cart.getQuantity(widget.restaurant) > 0
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CartScreen(
                      restaurant: widget.restaurant,
                    ),
                  ),
                );
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              cart.getQuantity(widget.restaurant).toString(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ver canasta',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${cart.getTotal(widget.restaurant).toString()}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
