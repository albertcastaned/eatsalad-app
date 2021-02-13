import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../exceptions/invalid_json_exception.dart';
import '../utils/api_utils.dart';

class MyProfile extends ChangeNotifier {
  Profile myProfile;

  bool firstTime;

  Future<bool> isFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool("firstTime");
      if (isFirstTime == null) {
        throw Exception("Not set");
      }
      firstTime = isFirstTime;
      return isFirstTime;
    } catch (error) {
      firstTime = false;

      return false;
    }
  }

  Future<void> removeFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("firstTime");
    notifyListeners();
  }

  Future<Profile> fetch({
    http.Client client,
    Map<String, dynamic> params,
    String token,
  }) async {
    if (token == null) {
      token = await FirebaseAuth.instance.currentUser.getIdToken();
    }
    final url = "$server/profile/me";
    try {
      final response = await ApiHandler.request(
        method: HTTP_METHOD.get,
        token: token,
        url: url,
        client: client,
      );

      myProfile = Profile.fromJson(response);
      notifyListeners();
      return myProfile;
    } on TimeoutException {
      rethrow;
    } on HttpException {
      rethrow;
    } on InvalidJsonException {
      rethrow;
    }
  }

  Future<Profile> update({
    @required Profile profile,
    http.Client client,
    Map<String, dynamic> params,
    String token,
  }) async {
    if (token == null) {
      token = await FirebaseAuth.instance.currentUser.getIdToken();
    }
    final url = "$server/profile/me/";
    try {
      final response = await ApiHandler.request(
        method: HTTP_METHOD.put,
        body: profile.toJson(),
        token: token,
        url: url,
        client: client,
      );

      myProfile = Profile.fromJson(response);
      notifyListeners();
      return myProfile;
    } on TimeoutException {
      rethrow;
    } on HttpException {
      rethrow;
    } on InvalidJsonException {
      rethrow;
    }
  }
}

class Profile {
  int id;
  String email;
  String phoneNumber;
  String firstName;
  String lastName;
  String stripeCustomerId;
  bool firstTime;

  Profile(
      {this.id,
      this.email,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.stripeCustomerId,
      this.firstTime});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phoneNumber = json['phone_number'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    stripeCustomerId = json['stripe_customer_id'];
    email = json['contact_email'];
    firstTime = json['first_time'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['contact_email'] = email;
    data['phone_number'] = phoneNumber;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['stripe_customer_id'] = stripeCustomerId;
    data['first_time'] = firstTime;
    return data;
  }

  @override
  String toString() {
    return "$id $firstName $lastName";
  }
}
