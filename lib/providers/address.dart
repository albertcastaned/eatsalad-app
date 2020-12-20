import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Address {
  String direction;
  String latitude;
  String longitude;

  Address(
      {@required this.direction,
      @required this.latitude,
      @required this.longitude});
}

class SelectedAddress extends ChangeNotifier {
  Address selectedAddress;
  Future<void> fetchSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final direction = prefs.getString("direction");
    final longitude = prefs.getString("longitude");
    final latitude = prefs.getString("latitude");

    if (direction == null || longitude == null || latitude == null) {
      print("Address not set");
      return;
    }
    selectedAddress = Address(
        direction: direction, longitude: longitude, latitude: latitude);

    notifyListeners();
  }
}
