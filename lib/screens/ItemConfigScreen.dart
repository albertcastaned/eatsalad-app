import 'package:EatSalad/providers/restaurants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_body.dart';
import '../widgets/counter.dart';

import '../providers/cart.dart';
import '../providers/items.dart';
import '../providers/orders.dart';

Map<Ingredient, int> _selectedIngredients = new Map<Ingredient, int>();
Map<Amenities, bool> _validGroups = new Map<Amenities, bool>();
int _quantity = 1;
double _price = 0.00;
bool _isValid = false;
final cartKey = new GlobalKey<ItemSetupAddToCartState>();
final notesTextController = TextEditingController();

class ItemSetup extends StatefulWidget {
  final Item item;
  ItemSetup({@required this.item, loaded = false});

  @override
  _ItemSetupState createState() => _ItemSetupState();
}

class _ItemSetupState extends State<ItemSetup> {
  @override
  void initState() {
    _selectedIngredients = new Map<Ingredient, int>();
    _validGroups = new Map<Amenities, bool>();

    for (Amenities amenities in widget.item.amenities) {
      if (amenities.obligatory) {
        _validGroups[amenities] = false;
      } else if (amenities.minimumSelect == 0) {
        _validGroups[amenities] = true;
      }
      for (Ingredient ingredient in amenities.amenity.ingredients) {
        _selectedIngredients[ingredient] = 0;
      }
    }
    _quantity = 1;
    notesTextController.text = "";
    _price = double.parse(widget.item.price);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      isFullScreen: true,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  ItemHeader(
                    item: widget.item,
                  ),
                  Divider(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, intex) => Divider(),
                    itemCount: widget.item.amenities.length,
                    itemBuilder: (context, index) => AmenitiesSection(
                      amenities: widget.item.amenities[index],
                    ),
                  ),
                  Divider(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 25,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextField(
                      controller: notesTextController,
                      maxLines: 5,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText:
                              "Añade comentarios o instrucciones especiales",
                          focusColor: Colors.green,
                          fillColor: Colors.redAccent),
                    ),
                  ),
                  Divider(),
                  ItemQuantityCounter()
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ItemSetupAddToCart(item: widget.item, key: cartKey),
          ),
        ],
      ),
    );
  }
}

class ItemQuantityCounter extends StatefulWidget {
  @override
  _ItemQuantityCounterState createState() => _ItemQuantityCounterState();
}

class _ItemQuantityCounterState extends State<ItemQuantityCounter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Counter(
        text: _quantity.toString(),
        onReduced: (_quantity > 1)
            ? () {
                setState(() {
                  _quantity--;
                  cartKey.currentState.updateTotal();
                });
              }
            : null,
        onAdded: () {
          setState(() {
            _quantity++;
            cartKey.currentState.updateTotal();
          });
        },
      ),
    );
  }
}

class ItemHeader extends StatelessWidget {
  final Item item;

  ItemHeader({@required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          item.image,
          fit: BoxFit.cover,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "\$${item.price}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class AmenitiesSection extends StatelessWidget {
  final Amenities amenities;
  AmenitiesSection({@required this.amenities});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
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
                if (amenities.fieldType != "R" && amenities.minimumSelect > 0)
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Minimo: ${amenities.minimumSelect}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 10,
                ),
                if (amenities.fieldType != "R" && amenities.maximumSelect > 0)
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
          IngredientsGroup(
            amenities: amenities,
          ),
        ],
      ),
    );
  }
}

class IngredientsGroup extends StatefulWidget {
  final Amenities amenities;

  IngredientsGroup({@required this.amenities});

  @override
  _IngredientsGroupState createState() => _IngredientsGroupState();
}

class _IngredientsGroupState extends State<IngredientsGroup> {
  int sum;
  int radioChosen;

  @override
  void initState() {
    sum = 0;
    radioChosen = null;

    super.initState();
  }

  void checkRequiredValid() {
    if (!widget.amenities.obligatory) return;

    _validGroups[widget.amenities] = sum >= widget.amenities.minimumSelect;
  }

  @override
  Widget build(BuildContext context) {
    void update() {
      checkRequiredValid();
      cartKey.currentState.updateTotal();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, intex) => Divider(),
        itemCount: widget.amenities.amenity.ingredients.length,
        itemBuilder: (context, index) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.amenities.amenity.ingredients[index].name,
                  style: TextStyle(fontSize: 18),
                ),
                if (double.parse(
                        widget.amenities.amenity.ingredients[index].price) >
                    0)
                  Text(
                    "+ \$${widget.amenities.amenity.ingredients[index].price}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            widget.amenities.fieldType == "R"
                ? Radio(
                    activeColor: Theme.of(context).primaryColor,
                    value: index,
                    groupValue: radioChosen,
                    onChanged: (value) {
                      setState(() {
                        sum = 1;
                        if (radioChosen != null)
                          _selectedIngredients[widget
                              .amenities.amenity.ingredients[radioChosen]] = 0;
                        _selectedIngredients[
                            widget.amenities.amenity.ingredients[value]] = 1;
                        radioChosen = value;
                        update();
                      });
                    },
                  )
                : widget.amenities.fieldType == "C"
                    ? Counter(
                        text: _selectedIngredients[
                                widget.amenities.amenity.ingredients[index]]
                            .toString(),
                        onAdded: (widget.amenities.maximumSelect > sum)
                            ? () {
                                setState(() {
                                  _selectedIngredients[widget
                                      .amenities.amenity.ingredients[index]]++;
                                  sum++;
                                  update();
                                });
                              }
                            : null,
                        onReduced: (_selectedIngredients[widget
                                    .amenities.amenity.ingredients[index]] >
                                0)
                            ? () {
                                setState(() {
                                  sum--;
                                  _selectedIngredients[widget
                                      .amenities.amenity.ingredients[index]]--;
                                  update();
                                });
                              }
                            : null,
                      )
                    : Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: (_selectedIngredients[
                                widget.amenities.amenity.ingredients[index]] >
                            0),
                        onChanged: (value) {
                          if (_selectedIngredients[
                                  widget.amenities.amenity.ingredients[index]] >
                              0) {
                            setState(() {
                              _selectedIngredients[widget
                                  .amenities.amenity.ingredients[index]] = 0;
                              sum--;
                              update();
                            });
                          } else if (widget.amenities.maximumSelect > sum) {
                            setState(() {
                              _selectedIngredients[widget
                                  .amenities.amenity.ingredients[index]] = 1;
                              sum++;
                              update();
                            });
                          }
                        },
                      ),
          ],
        ),
      ),
    );
  }
}

class ItemSetupAddToCart extends StatefulWidget {
  final Item item;
  ItemSetupAddToCart({@required this.item, Key key}) : super(key: key);
  @override
  ItemSetupAddToCartState createState() => ItemSetupAddToCartState();
}

class ItemSetupAddToCartState extends State<ItemSetupAddToCart> {
  @override
  void initState() {
    updateTotal();
    super.initState();
  }

  void updateTotal() {
    setState(() {
      print("Price calculated");
      double ingredientSum = 0.00;
      _selectedIngredients.forEach(
        (key, value) {
          ingredientSum += double.parse(key.price) * value;
        },
      );
      _price = (double.parse(widget.item.price) + ingredientSum) * _quantity;
      _isValid = true;
      _validGroups.forEach((key, value) {
        if (!value) _isValid = false;
        return;
      });
      print("Required fields: $_isValid");
    });
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.all(20),
      onPressed: _isValid
          ? () {
              List<OrderItemIngredient> orderItemIngredients =
                  new List<OrderItemIngredient>();

              if (_selectedIngredients != null) {
                _selectedIngredients.forEach((key, value) {
                  if (value > 0) {
                    orderItemIngredients.add(
                      OrderItemIngredient(
                        name: key.name,
                        price: key.price,
                        quantity: value,
                      ),
                    );
                  }
                });
              }
              final orderItem = OrderItem(
                restaurant:
                    Provider.of<RestaurantProvider>(context, listen: false)
                        .selectedRestaurant,
                name: widget.item.name,
                quantity: _quantity,
                notes: notesTextController.text,
                price: _price.toString(),
                ingredients: orderItemIngredients,
              );
              Provider.of<Cart>(context, listen: false).addToCart(
                  Provider.of<RestaurantProvider>(context, listen: false)
                      .selectedRestaurant,
                  orderItem);
              Navigator.of(context).pop();
            }
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Agregar $_quantity al carrito',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            "\$${_price.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
