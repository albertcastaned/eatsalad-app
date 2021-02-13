import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/restaurants.dart';
import '../widgets/app_card.dart';
import '../widgets/content_loader.dart';
import 'items_screen.dart';

class RestaurantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: ContentLoader(
              allowRefresh: true,
              future: Provider.of<Restaurants>(context, listen: false).fetch,
              widget: Consumer<Restaurants>(
                builder: (ctx, data, child) => ListView.separated(
                  separatorBuilder: (context, intex) => Divider(),
                  itemCount: data.items.length,
                  itemBuilder: (context, index) => RestaurantCard(
                      restaurant: data.items[index],
                      available: !data.items[index].outOfRange),
                ),
              ),
            ),
          ),
        ],
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
                Provider.of<Restaurants>(context, listen: false)
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
                    child: Image.network(
                      restaurant.image,
                      height: 125,
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
                        "Horario: "
                        // ignore: lines_longer_than_80_chars
                        "${restaurant.schedule.startTime} - ${restaurant.schedule.endTime}",
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
