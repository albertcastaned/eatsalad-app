import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../providers/restaurants.dart';
import '../widgets/app_body.dart';
import '../widgets/content_loader.dart';

var googlePlace = GooglePlace(googleApiKey);

class AddressSetupScreen extends StatefulWidget {
  static const routeName = '/address';

  @override
  _AddressSetupScreenState createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen> {
  Future<AutocompleteResponse> _searchFuture;
  AutocompleteResponse _results;

  Future<void> getGooglePlacesResults(String query) async {
    if (query.isEmpty) return null;

    _results = await googlePlace.autocomplete.get(query,
        language: "es",
        types: "address",
        components: [Component("country", "mx")]);

    setState(() {});
  }

  Widget selectedAddress;
  Future<void> attemptLoadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final longitude = prefs.getString("longitude");
      final latitude = prefs.getString("latitude");
      final direction = prefs.getString("direction");

      if (longitude == null || latitude == null || direction == null) return;
      selectedAddress = LocationCard(
        direction: direction,
        longitude: longitude,
        latitude: latitude,
        selected: true,
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    attemptLoadPrefs().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      title: 'Elegir ubicacion',
      isFullScreen: true,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchFuture = getGooglePlacesResults(value);
                  });
                },
              ),
              if (_results != null)
                ContentLoader(
                  future: _searchFuture,
                  widget: Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => LocationCard(
                        direction: _results.predictions[index].description,
                        placeId: _results.predictions[index].placeId,
                      ),
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _results.predictions.length,
                    ),
                  ),
                ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              SizedBox(
                height: 15,
              ),
              if (selectedAddress != null) selectedAddress,
              SizedBox(
                height: 15,
              ),
              Divider(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String direction;
  final String latitude;
  final String longitude;
  final String placeId;
  final bool selected;

  LocationCard({
    @required this.direction,
    this.latitude,
    this.longitude,
    this.placeId,
    this.selected = false,
  });

  Future<void> saveSelectedCoordinates(
      BuildContext context, String latitude, String longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("direction", direction);
      prefs.setString("latitude", latitude);
      prefs.setString("longitude", longitude);

      print("New coordinates saved succesfully");

      // TODO: Find better way to do this ?
      // Fetch restaurants again
      Provider.of<Restaurants>(context, listen: false).fetch();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !selected
          ? () {
              if (latitude == null || longitude == null) {
                assert(placeId != null);

                googlePlace.details.get(placeId).then((value) {
                  final newLatitude =
                      value.result.geometry.location.lat.toString();
                  final newLongitude =
                      value.result.geometry.location.lng.toString();
                  saveSelectedCoordinates(context, newLatitude, newLongitude);
                });
              } else {
                saveSelectedCoordinates(context, latitude, longitude);
              }
              Navigator.of(context).pop();
            }
          : null,
      child: Container(
        child: ListTile(
          leading: Icon(Icons.my_location),
          title: Text(direction),
          trailing: selected ? Text('Seleccionado') : null,
        ),
      ),
    );
  }
}
