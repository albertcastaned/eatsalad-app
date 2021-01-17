import 'dart:async';

import 'package:EatSalad/providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import '../test_utils.dart';

void main() {
  var mockFirebaseAuth = MockFirebaseAuth();
  final googleSignIn = MockGoogleSignIn();
  final auth = Auth(
    auth: mockFirebaseAuth,
    googleSignIn: googleSignIn,
  );
  group('Firebase sign in with email and password', () {
    test('returns a user credential', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: "email@gmai.com", password: "test123^#"))
          .thenAnswer((_) async => MockUserCredential());

      expect(await auth.signInWithEmail("email@gmai.com", "test123^#"),
          isA<UserCredential>());
    });
    test('throws timeout exception', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: "email@gmai.com", password: "test123^#"))
          .thenAnswer((_) async => throw TimeoutException('Timeout'));

      expect(auth.signInWithEmail("email@gmai.com", "test123^#"),
          throwsA(isA<TimeoutException>()));
    });
    test('throws account doesnt exist exception', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: "email@gmai.com", password: "test123^#"))
          .thenAnswer((_) async =>
              throw FirebaseAuthException(message: 'Test error message'));

      expect(auth.signInWithEmail("email@gmai.com", "test123^#"),
          throwsA(isA<FirebaseAuthException>()));
    });
  });

  group('Firebase sign up with email and password', () {
    test('is successful', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: "email@gmai.com", password: "test123^#"))
          .thenAnswer((_) async => MockUserCredential());

      expect(
          await auth.signUpEmailPassword("email@gmai.com", "test123^#"), true);
    });
    test('throws timeout exception', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: "email@gmai.com", password: "test123^#"))
          .thenAnswer((_) async => throw TimeoutException('Timeout'));

      expect(auth.signUpEmailPassword("email@gmai.com", "test123^#"),
          throwsA(isA<TimeoutException>()));
    });
    test('throws account doesnt exist exception', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: "email@gmai.com", password: "test123^#"))
          .thenAnswer((_) async =>
              throw FirebaseAuthException(message: 'Test error message'));

      expect(auth.signUpEmailPassword("email@gmai.com", "test123^#"),
          throwsA(isA<FirebaseAuthException>()));
    });
  });

  group('Firebase sign in with google', () {
    final credential = GoogleAuthProvider.credential(
      idToken: 'test',
      accessToken: 'test',
    );
    test('returns a user credential', () async {
      when(mockFirebaseAuth.signInWithCredential(credential))
          .thenAnswer((_) async => MockUserCredential());
      expect(
          await auth.authenticateWithGoogle(credential), isA<UserCredential>());
    });
    test('throws timeout exception', () async {
      when(mockFirebaseAuth.signInWithCredential(credential))
          .thenAnswer((_) async => throw TimeoutException('Timeout'));

      expect(auth.authenticateWithGoogle(credential),
          throwsA(isA<TimeoutException>()));
    });
    test('throws account doesnt exist exception', () async {
      when(mockFirebaseAuth.signInWithCredential(credential)).thenAnswer(
          (_) async =>
              throw FirebaseAuthException(message: 'Test error message'));

      expect(auth.authenticateWithGoogle(credential),
          throwsA(isA<FirebaseAuthException>()));
    });
  });
}
