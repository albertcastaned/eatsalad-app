import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../providers/address.dart';
import '../providers/profile.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_body.dart';
import '../widgets/content_loader.dart';
import 'home_screen.dart';

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
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final firstTime =
        (args == null || args['firstTime'] == null) ? false : args['firstTime'];
    return AppBody(
      title: 'Busca tu ubicacion',
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
                FutureBuilder(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingWidget();
                    } else if (snapshot.hasError) {
                      return Text('Ocurrio un error de conexion');
                    } else {
                      return Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => LocationCard(
                            direction: _results.predictions[index].description,
                            placeId: _results.predictions[index].placeId,
                            firstTime: firstTime,
                          ),
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _results.predictions.length,
                        ),
                      );
                    }
                  },
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
  final bool firstTime;
  LocationCard({
    @required this.direction,
    this.latitude,
    this.longitude,
    this.placeId,
    this.selected = false,
    this.firstTime,
  });

  Future<void> saveSelectedCoordinates(
      BuildContext context, String latitude, String longitude) async {
    try {
      await Provider.of<SelectedAddress>(context, listen: false)
          .setAddress(direction, latitude, longitude);

      if (firstTime) {
        await showSuccesfulDialog(
          context,
          "Ha terminado la configuracion inicial."
          " Puede volver a cambiar estos datos desde 'Mi Perfil'",
        );

        await Provider.of<MyProfile>(context, listen: false).removeFirstTime();

        Navigator.of(context).popAndPushNamed(HomeScreen.routeName);
      } else {
        Navigator.of(context).pop();
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !selected
          ? () async {
              if (latitude == null || longitude == null) {
                assert(placeId != null);

                googlePlace.details.get(placeId).then((value) async {
                  final newLatitude =
                      value.result.geometry.location.lat.toString();
                  final newLongitude =
                      value.result.geometry.location.lng.toString();
                  await saveSelectedCoordinates(
                      context, newLatitude, newLongitude);
                });
              } else {
                await saveSelectedCoordinates(context, latitude, longitude);
              }
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
