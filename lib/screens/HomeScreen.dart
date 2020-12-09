import 'package:EatSalad/screens/AddCardScreen.dart';
import 'package:EatSalad/screens/CardListScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/restaurants.dart';
import '../widgets/app_body.dart';
import '../widgets/app_card.dart';
import '../widgets/content_loader.dart';
import './AddressSetupScreen.dart';
import './ItemsScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _future;
  @override
  void initState() {
    _future = Provider.of<RestaurantProvider>(context, listen: false)
        .fetchRestaurants();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      await Provider.of<Auth>(context, listen: false).logout();
    }

    return AppBody(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ContentLoader(
                future: _future,
                widget: Consumer<RestaurantProvider>(
                  builder: (ctx, data, child) => Flexible(
                    child: RefreshIndicator(
                      onRefresh: () => _future =
                          Provider.of<RestaurantProvider>(context,
                                  listen: false)
                              .fetchRestaurants(),
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, intex) => Divider(),
                        itemCount: data.restaurants.length,
                        itemBuilder: (context, index) => RestaurantCard(
                            restaurant: data.restaurants[index],
                            available: !data.restaurants[index].outOfRange),
                      ),
                    ),
                  ),
                ),
              ),
              RaisedButton(
                child: Text('Config ubicacion'),
                onPressed: () {
                  Navigator.of(context).pushNamed(AddressSetupScreen.routeName);
                },
              ),
              RaisedButton(
                child: Text('Cerrar sesion'),
                onPressed: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final double radius = 15;
  final bool available;
  RestaurantCard({@required this.restaurant, this.available = true});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: available
            ? () {
                Provider.of<RestaurantProvider>(context, listen: false)
                    .selectedRestaurant = restaurant;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemsScreen(
                      restaurant: restaurant,
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius)),
                    child: restaurant.image != null
                        ? Image.network(
                            restaurant.image,
                            height: 125,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        //TODO: Add default image
                        : null,
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
                        restaurant.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!available)
                    Positioned(
                      top: 0,
                      right: 5,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(radius)),
                        child: Text(
                          "No Disponible",
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
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Costo de envio: \$${restaurant.deliveryFee}",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "Minimo por pedido: \$${restaurant.minimumOrderCost}",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "Horario: ${restaurant.schedule.startTime} - ${restaurant.schedule.endTime}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
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
