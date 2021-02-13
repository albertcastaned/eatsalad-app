import 'dart:async';
import 'dart:convert';

import 'package:EatSalad/providers/profile.dart';
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

  Future<void> authenticate(UserCredential userCredentials,
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

      print(response);
      final profile = Profile.fromJson(response);
      final prefs = await SharedPreferences.getInstance();

      if (profile.firstTime) {
        // Set shared preference data so user does profile setup
        print("User is new");
        prefs.setBool('firstTime', true);
      } else {
        print("User is not new.");
        prefs.setBool('firstTime', false);
      }
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
}
