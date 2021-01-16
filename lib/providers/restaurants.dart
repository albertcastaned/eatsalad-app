import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../exceptions/invalid_json_exception.dart';
import '../utils/api_utils.dart';
import '../utils/location_utils.dart';

import 'api_provider.dart';
import 'base_model.dart';

class Restaurant implements BaseModel {
  int id;
  Schedule schedule;
  String name;
  String image;
  String address;
  String state;
  String city;
  String minimumOrderCost;
  String deliveryFee;
  double areaCoverage;
  bool available;
  double latitude;
  double longitude;
  bool outOfRange = false;
  Restaurant({
    id,
    schedule,
    name,
    address,
    image,
    state,
    city,
    minimumOrderCost,
    deliveryFee,
    areaCoverage,
    available,
    latitude,
    longitude,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    schedule =
        json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null;
    image = json['image'];
    name = json['name'];
    address = json['address'];
    state = json['state'];
    city = json['city'];
    minimumOrderCost = json['minimum_order_cost'];
    deliveryFee = json['delivery_fee'];
    areaCoverage = double.parse(json['areaCoverage']);
    available = json['available'];
    longitude = double.parse(json['longitude']);
    latitude = double.parse(json['latitude']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    if (schedule != null) {
      data['schedule'] = schedule.toJson();
    }
    data['name'] = name;
    data['address'] = address;
    data['state'] = state;
    data['city'] = city;
    data['minimum_order_cost'] = minimumOrderCost;
    data['delivery_fee'] = deliveryFee;
    data['areaCoverage'] = areaCoverage;
    data['available'] = available;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }

  @override
  List<String> requiredKeys;
}

class Schedule implements BaseModel {
  int id;
  String startTime;
  String endTime;
  bool availableSunday;
  bool availableMonday;
  bool availableTuesday;
  bool availableWednesday;
  bool availableThursday;
  bool availableFriday;
  bool availableSaturday;

  Schedule(
      {id,
      startTime,
      endTime,
      availableSunday,
      availableMonday,
      availableTuesday,
      availableWednesday,
      availableThursday,
      availableFriday,
      availableSaturday});

  Schedule.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);

    id = json['id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    availableSunday = json['available_sunday'];
    availableMonday = json['available_monday'];
    availableTuesday = json['available_tuesday'];
    availableWednesday = json['available_wednesday'];
    availableThursday = json['available_thursday'];
    availableFriday = json['available_friday'];
    availableSaturday = json['available_saturday'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['available_sunday'] = availableSunday;
    data['available_monday'] = availableMonday;
    data['available_tuesday'] = availableTuesday;
    data['available_wednesday'] = availableWednesday;
    data['available_thursday'] = availableThursday;
    data['available_friday'] = availableFriday;
    data['available_saturday'] = availableSaturday;
    return data;
  }

  @override
  List<String> requiredKeys = [
    'start_time',
    'end_time',
    'available_sunday',
    'available_monday',
    'available_tuesday',
    'available_wednesday',
    'available_thursday',
    'available_friday',
    'available_saturday',
  ];
}

class Restaurants extends ApiProvider {
  Restaurant selectedRestaurant;

  @override
  Future<bool> fetch(
      {http.Client client, Map<String, dynamic> params, String token}) async {
    try {
      if (token == null) {
        token = await FirebaseAuth.instance.currentUser.getIdToken();
      }

      final url = "$server/restaurants";
      final response = await ApiHandler.request(
        method: HTTP_METHOD.get,
        url: url,
        token: token,
        client: client,
      );

      items =
          (response as List).map((item) => Restaurant.fromJson(item)).toList();

      notifyListeners();
      return true;
    } on TimeoutException {
      rethrow;
    } on HttpException {
      rethrow;
    } on InvalidJsonException {
      rethrow;
    }
  }

  void setOutOfRange() async {
    // Get current selected coordinates
    final prefs = await SharedPreferences.getInstance();
    final longitude = prefs.getString("longitude");
    final latitude = prefs.getString("latitude");
    if (longitude != null && latitude != null) {
      for (var restaurant in items) {
        final distance = distanceBetweenPoints(
          restaurant.latitude,
          restaurant.longitude,
          double.parse(latitude),
          double.parse(longitude),
        );
        restaurant.outOfRange = distance > restaurant.areaCoverage;
      }
    }
  }

  @override
  Future post({item, http.Client client, String token}) {
    throw UnimplementedError();
  }
}
