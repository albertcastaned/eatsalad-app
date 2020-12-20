import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../exceptions/authentication_exception.dart';
import '../utils.dart';

class Auth extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _googleSignIn = GoogleSignIn();

  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> _authenticate(UserCredential userCredential) async {
    final apiUrl = "$server/profile/";

    try {
      final idToken = await userCredential.user.getIdToken();

      final response = await apiGet(apiUrl, requestApiHeaders(idToken));

      // Save profile as json in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final myProfile = Profile.fromJson(response['profile']);
      prefs.setString("profile", jsonEncode(myProfile));
      print(jsonEncode(myProfile));
      print('Api auth succeded');
      notifyListeners();
    } on TimeoutException catch (e) {
      print(e);
      throw TimeoutException('Time out');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    print("User signed out");
    notifyListeners();
  }

  Future<void> signUpEmailPassword(
      BuildContext context, String email, String password) async {
    final loadingDialog = buildLoadingDialog(context, 'Creando usuario...');
    await loadingDialog.show();

    try {
      final user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      assert(user != null);
    } catch (error) {
      rethrow;
    } finally {
      loadingDialog.hide();
    }
  }

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    var dialog = buildLoadingDialog(context, 'Iniciando sesión...');
    await dialog.show();

    try {
      final authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      assert(authResult != null);
      assert(authResult.user.uid.isNotEmpty);
      print("Firebase auth succeded");

      await _authenticate(authResult);
    } catch (error) {
      rethrow;
    } finally {
      dialog.hide();
    }
  }

  Future<dynamic> authenticateWithGoogle(BuildContext context) async {
    GoogleSignInAuthentication googleSignInAuthentication;
    GoogleSignInAccount googleSignInAccount;
    try {
      googleSignInAccount = await _googleSignIn.signIn();

      googleSignInAuthentication = await googleSignInAccount.authentication;
    } catch (error) {
      throw AuthenticationException("Google flow cancelled");
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    final authResult = await _auth.signInWithCredential(credential);
    final user = authResult.user;
    assert(!user.isAnonymous);

    final currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    print("Firebase auth succeded");

    var dialog = buildLoadingDialog(context, 'Iniciando sesión...');
    await dialog.show();

    try {
      await _authenticate(authResult);
    } catch (error) {
      rethrow;
    } finally {
      dialog.hide();
    }

    print('Signed in with google succesfully: $user');
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
