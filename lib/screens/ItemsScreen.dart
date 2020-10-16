import 'package:EatSalad/providers/restaurants.dart';
import 'package:EatSalad/widgets/app_body.dart';
import 'package:EatSalad/widgets/app_card.dart';
import 'package:EatSalad/widgets/content_loader.dart';
import 'package:EatSalad/widgets/counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/items.dart';

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

    _future = Provider.of<CategoriesProvider>(context, listen: false)
        .fetchCategories(widget.restaurant.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      isFullScreen: true,
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
                        itemCount: categoryData.categories.length,
                        itemBuilder: (context, index) => CategorySection(
                            category: categoryData.categories[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: OrderCartPreview(),
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
          new MaterialPageRoute(
            builder: (BuildContext context) {
              return new ItemSetup(item: item);
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
            Expanded(
              flex: 3,
              child: Column(
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
  @override
  _OrderCartPreviewState createState() => _OrderCartPreviewState();
}

class _OrderCartPreviewState extends State<OrderCartPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "0",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Ver canasta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            "\$20",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ItemSetup extends StatefulWidget {
  final Item item;
  ItemSetup({@required this.item});
  @override
  _ItemSetupState createState() => _ItemSetupState();
}

class _ItemSetupState extends State<ItemSetup> {
  @override
  Widget build(BuildContext context) {
    return AppBody(
      isFullScreen: true,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  widget.item.image,
                  fit: BoxFit.cover,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, intex) => Divider(),
                  itemCount: widget.item.amenities.length,
                  itemBuilder: (context, index) => AmenitiesSection(
                    amenities: widget.item.amenities[index],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ItemSetupAddToCart(),
          ),
        ],
      ),
    );
  }
}

class AmenitiesSection extends StatelessWidget {
  final Amenities amenities;
  AmenitiesSection({@required this.amenities});
  @override
  Widget build(BuildContext context) {
    int test = 1;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Text(
                amenities.amenity.name,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              if (amenities.maximumSelect > 0)
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Maximo: ${amenities.maximumSelect}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              SizedBox(
                width: 10,
              ),
              if (amenities.obligatory)
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Obligatorio",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, intex) => Divider(),
          itemCount: amenities.amenity.ingredients.length,
          itemBuilder: (context, index) => CounterListView(
            title: amenities.amenity.ingredients[index].name,
            minValue: 1,
            maxValue: amenities.maximumSelect,
            onPressed: null,
          ),
        ),
      ],
    );
  }
}

class ItemSetupAddToCart extends StatefulWidget {
  @override
  _ItemSetupAddToCartState createState() => _ItemSetupAddToCartState();
}

class _ItemSetupAddToCartState extends State<ItemSetupAddToCart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Agregar a carrito',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            "\$20",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
