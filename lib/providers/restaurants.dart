import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../constants.dart';
import '../utils.dart';

class Restaurant {
  int id;
  Schedule schedule;
  String name;
  String image;
  String address;
  String state;
  String city;
  String minimumOrderCost;
  String deliveryFee;
  int areaCoverage;
  bool available;

  Restaurant(
      {this.id,
      this.schedule,
      this.name,
      this.address,
      this.image,
      this.state,
      this.city,
      this.minimumOrderCost,
      this.deliveryFee,
      this.areaCoverage,
      this.available});

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    schedule = json['schedule'] != null
        ? new Schedule.fromJson(json['schedule'])
        : null;
    image = json['image'];
    name = json['name'];
    address = json['address'];
    state = json['state'];
    city = json['city'];
    minimumOrderCost = json['minimum_order_cost'];
    deliveryFee = json['delivery_fee'];
    areaCoverage = json['areaCoverage'];
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.schedule != null) {
      data['schedule'] = this.schedule.toJson();
    }
    data['name'] = this.name;
    data['address'] = this.address;
    data['state'] = this.state;
    data['city'] = this.city;
    data['minimum_order_cost'] = this.minimumOrderCost;
    data['delivery_fee'] = this.deliveryFee;
    data['areaCoverage'] = this.areaCoverage;
    data['available'] = this.available;
    return data;
  }
}

class Schedule {
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
      {this.id,
      this.startTime,
      this.endTime,
      this.availableSunday,
      this.availableMonday,
      this.availableTuesday,
      this.availableWednesday,
      this.availableThursday,
      this.availableFriday,
      this.availableSaturday});

  Schedule.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['available_sunday'] = this.availableSunday;
    data['available_monday'] = this.availableMonday;
    data['available_tuesday'] = this.availableTuesday;
    data['available_wednesday'] = this.availableWednesday;
    data['available_thursday'] = this.availableThursday;
    data['available_friday'] = this.availableFriday;
    data['available_saturday'] = this.availableSaturday;
    return data;
  }
}

class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> restaurants;

  Future<void> fetchRestaurants() async {
    try {
      final apiUrl = "${Constants.server}/restaurants";
      String token = await FirebaseAuth.instance.currentUser.getIdToken();
      final response = await apiGet(apiUrl, requestApiHeaders(token))
          .timeout(Duration(seconds: Constants.timeoutSeconds));

      restaurants =
          (response as List).map((item) => Restaurant.fromJson(item)).toList();
      return restaurants;
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }
}
