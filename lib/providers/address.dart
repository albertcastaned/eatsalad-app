import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Address {
  String direction;
  String latitude;
  String longitude;

  Address(
      {@required this.direction,
      @required this.latitude,
      @required this.longitude});
}

class SelectedAddress with ChangeNotifier {
  Address selectedAddress;
  Future<void> fetchSelectedAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String direction = prefs.getString("direction");
    final String longitude = prefs.getString("longitude");
    final String latitude = prefs.getString("latitude");

    if (direction == null || longitude == null || latitude == null) {
      print("Address not set");
      return;
    }
    selectedAddress = new Address(
        direction: direction, longitude: longitude, latitude: latitude);

    notifyListeners();
  }
}
