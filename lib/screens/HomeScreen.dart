import 'package:EatSalad/providers/restaurants.dart';
import 'package:EatSalad/screens/ItemsScreen.dart';
import 'package:EatSalad/widgets/app_body.dart';
import 'package:EatSalad/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../widgets/content_loader.dart';

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

    return Scaffold(
      body: AppBody(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ContentLoader(
                    future: _future,
                    widget: Consumer<RestaurantProvider>(
                      builder: (ctx, restaurantData, child) =>
                          ListView.separated(
                              separatorBuilder: (context, intex) => Divider(),
                              itemCount: restaurantData.restaurants.length,
                              itemBuilder: (context, index) => RestaurantCard(
                                    restaurant:
                                        restaurantData.restaurants[index],
                                  )),
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text('Cerrar sesion'),
                  onPressed: logout,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final double radius = 15;
  RestaurantCard({@required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ItemsScreen(
                restaurant: restaurant,
              ),
            ),
          );
        },
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
