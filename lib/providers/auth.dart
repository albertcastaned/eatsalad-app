import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../exceptions/authentication_exception.dart';

import '../constants.dart';
import '../utils.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _googleSignIn = GoogleSignIn();

  Future<bool> isLoggedIn() async {
    return await _auth.currentUser() != null;
  }

  Future<void> _authenticate(AuthResult authResult) async {
    final apiUrl = "${Constants.server}/profile/";

    try {
      IdTokenResult idToken = await authResult.user.getIdToken();

      await apiGet(apiUrl, requestApiHeaders(idToken.token));

      print('Api auth succeded');
      notifyListeners();
    } on TimeoutException catch (e) {
      print(e);
      throw new TimeoutException('Time out');
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    _auth.signOut();
    print("User signed out");
    notifyListeners();
  }

  Future<void> signUpEmailPassword(
      BuildContext context, String email, String password) async {
    ProgressDialog loadingDialog =
        buildLoadingDialog(context, 'Creando usuario...');
    await loadingDialog.show();

    try {
      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      assert(user != null);
    } catch (error) {
      throw error;
    } finally {
      loadingDialog.hide();
    }
  }

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    ProgressDialog dialog = buildLoadingDialog(context, 'Iniciando sesión...');
    await dialog.show();

    try {
      final AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      assert(authResult != null);
      assert(authResult.user.uid.isNotEmpty);
      print("Firebase auth succeded");

      await _authenticate(authResult);
    } catch (error) {
      throw error;
    } finally {
      dialog.hide();
    }
  }

  Future<dynamic> authenticateWithGoogle(BuildContext context) async {
    GoogleSignInAuthentication googleSignInAuthentication;
    GoogleSignInAccount googleSignInAccount;
    googleSignInAccount = await _googleSignIn.signIn();

    try {
      googleSignInAuthentication = await googleSignInAccount.authentication;
    } catch (error) {
      throw AuthenticationException("Google flow cancelled");
    }

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    print("Firebase auth succeded");

    ProgressDialog dialog = buildLoadingDialog(context, 'Iniciando sesión...');
    await dialog.show();

    try {
      await _authenticate(authResult);
    } catch (error) {
      throw error;
    } finally {
      dialog.hide();
    }

    print('Signed in with google succesfully: $user');
  }
}
