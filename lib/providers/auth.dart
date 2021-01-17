import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../utils/api_utils.dart';

class Auth extends ChangeNotifier {
  Auth({
    @required this.auth,
    @required this.googleSignIn,
  });

  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  bool get isLoggedIn => auth.currentUser != null;

  Future<bool> authenticate(UserCredential userCredentials,
      [http.Client client]) async {
    final url = "$server/profile/";

    try {
      final token = await userCredentials.user.getIdToken();

      final response = await ApiHandler.request(
        method: HTTP_METHOD.get,
        url: url,
        token: token,
        client: client,
      );

      // Save profile as json in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final myProfile = Profile.fromJson(response['profile']);
      prefs.setString("profile", jsonEncode(myProfile));
      print(jsonEncode(myProfile));
      print('Api auth succeded');
      notifyListeners();
      return true;
    } on TimeoutException catch (e) {
      print(e);
      throw TimeoutException('Time out');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    await googleSignIn.signOut();
    print("User signed out");
    notifyListeners();
  }

  Future<bool> signUpEmailPassword(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      assert(userCredential != null);
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } on TimeoutException {
      throw TimeoutException('Petition time run out');
    }
  }

  Future<UserCredential> authenticateWithGoogle(
      [OAuthCredential credential]) async {
    GoogleSignInAuthentication googleSignInAuthentication;
    GoogleSignInAccount googleSignInAccount;
    if (credential == null) {
      try {
        googleSignInAccount = await googleSignIn.signIn();
        googleSignInAuthentication = await googleSignInAccount.authentication;
      } catch (error) {
        throw PlatformException(code: 'Cancelled');
      }

      credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
    }

    try {
      final userCredential = await auth.signInWithCredential(credential);
      return userCredential;
    } on TimeoutException {
      rethrow;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<Profile> fetchMyProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print(prefs.getString("profile"));
      final profile = prefs.getString("profile");
      if (profile == null) {
        throw Exception('Profile not set');
      } else {
        Map<String, dynamic> profileMap;
        profileMap = jsonDecode(profile) as Map<String, dynamic>;
        var myProfile = Profile.fromJson(profileMap);
        return myProfile;
      }
    } catch (error) {
      rethrow;
    }
  }
}

class Profile {
  int id;
  String phoneNumber;
  String firstName;
  String lastName;
  String stripeCustomerId;

  Profile(
      {this.id,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.stripeCustomerId});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phoneNumber = json['phone_number'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    stripeCustomerId = json['stripe_customer_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['phone_number'] = phoneNumber;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['stripe_customer_id'] = stripeCustomerId;
    return data;
  }

  @override
  String toString() {
    return "$id $firstName $lastName";
  }
}
