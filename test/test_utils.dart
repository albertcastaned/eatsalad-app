import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:EatSalad/providers/api_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/test.dart';
import 'package:path/path.dart';

String loadResource(String name) =>
    File("$_testDirectory/fixtures/$name").readAsStringSync();

final _testDirectory = join(
  Directory.current.path,
  Directory.current.path.endsWith('test') ? '' : 'test',
);

class MockClient extends Mock implements http.Client {}

void apiPostBaseTest(
    {dynamic item, String name, ApiProvider provider, bool skip = false}) {
  group(
    '$name provider',
    () {
      test('posts succesfully', () async {
        final client = MockClient();

        when(
          client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{}', 200),
        );
        await provider.post(
          item: item,
          client: client,
          token: 'test',
        );

        verify(
          client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('throws timeout', () async {
        final client = MockClient();

        when(
          client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => throw TimeoutException('Time out error'));
        expect(
            provider.post(
              item: item,
              client: client,
              token: 'test',
            ),
            throwsA(isA<TimeoutException>()));

        verify(
          client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('throws http exception', () async {
        final client = MockClient();

        when(
          client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{}', 400));
        expect(
            provider.post(
              item: item,
              client: client,
              token: 'test',
            ),
            throwsA(isA<HttpException>()));

        verify(
          client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });
    },
    skip: skip ? "Test not implemented or skipped" : false,
  );
}

void apiBaseTest({
  String name = "Unset name",
  ApiProvider provider,
  String fixtureFileName,
  Map<String, dynamic> params,
  bool many = true,
  bool skip = false,
}) {
  group('$name provider', () {
    test('fetches and creates succesfully', () async {
      final client = MockClient();

      final fixture = loadResource(fixtureFileName);
      final jsonSize = many ? (json.decode(fixture) as List).length : 1;

      when(
        client.get(
          any,
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(fixture, 200),
      );
      final success =
          await provider.fetch(client: client, token: 'test', params: params);
      expect(success, true);

      expect(provider.items.length, jsonSize);
      verify(
        client.get(
          any,
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });

    test('throws timeout', () async {
      final client = MockClient();

      when(
        client.get(
          any,
          headers: anyNamed('headers'),
        ),
      ).thenAnswer((_) async => throw TimeoutException('Time out error'));
      expect(
          provider.fetch(
            client: client,
            token: 'test',
            params: params,
          ),
          throwsA(isA<TimeoutException>()));

      verify(
        client.get(
          any,
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });

    test('throws http exception', () async {
      final client = MockClient();

      when(
        client.get(
          any,
          headers: anyNamed('headers'),
        ),
      ).thenAnswer((_) async => throw HttpException('Http exception'));
      expect(
          provider.fetch(
            client: client,
            token: 'test',
            params: params,
          ),
          throwsA(isA<HttpException>()));

      verify(
        client.get(
          any,
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });
    if (params != null) {
      test('validates required parameters', () async {
        final client = MockClient();
        final success = await provider.fetch(
          client: client,
          token: 'test',
        );
        expect(success, false);
      });
    }
  }, skip: skip ? "Test not implemented or skipped" : false);
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {
  MockUserCredential();
}
