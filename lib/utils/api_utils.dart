import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart' as constants;
import '../exceptions/invalid_json_exception.dart';

enum HTTP_METHOD { get, post, patch, put, delete }

class ApiHandler {
  /// Makes a [HTTP_METHOD] type request to [url]
  ///
  /// Returns a JSON object when succesful
  ///
  /// Throws a [TimeoutException] if time exceeded. Throws a [HttpException] if
  /// the HTTP request returns a >=400 status code.
  static Future<dynamic> request({
    @required HTTP_METHOD method,
    @required String url,
    String token,
    Map<String, dynamic> body,
    http.Client client,
  }) async {
    if (client == null) {
      client = http.Client();
    }
    if (!constants.isTesting) print("Making a ${method.toString()} to $url.");
    if (body != null && !constants.isTesting) print("Body: $body");

    final headers = (token != null)
        ? {
            "Content-Type": "application/json",
            "Authorization": "JWT $token",
          }
        : {
            "Content-Type": "application/json",
          };
    if (!constants.isTesting) print("Headers: $headers");

    try {
      http.Response response;
      switch (method) {
        case HTTP_METHOD.get:
          response = await client
              .get(
                url,
                headers: headers,
              )
              .timeout(Duration(seconds: constants.timeoutSeconds));
          break;
        case HTTP_METHOD.post:
          response = await client
              .post(
                url,
                headers: headers,
                body: json.encode(body),
              )
              .timeout(Duration(seconds: constants.timeoutSeconds));
          ;
          break;
        case HTTP_METHOD.patch:
          response = await client
              .patch(
                url,
                headers: headers,
                body: json.encode(body),
              )
              .timeout(Duration(seconds: constants.timeoutSeconds));
          ;
          break;
        case HTTP_METHOD.put:
          response = await client
              .put(
                url,
                headers: headers,
                body: json.encode(body),
              )
              .timeout(Duration(seconds: constants.timeoutSeconds));
          ;
          break;
        case HTTP_METHOD.delete:
          response = await client
              .delete(
                url,
                headers: headers,
              )
              .timeout(Duration(seconds: constants.timeoutSeconds));
          ;
          break;
      }
      if (!constants.isTesting) {
        print("Status Code: ${response.statusCode}");
        print("Body: ${response.body}");
      }

      if (response.statusCode >= 400) {
        throw HttpException(response.body);
      }

      return json.decode(response.body);
    } on TimeoutException catch (error) {
      print(error);
      rethrow;
    }
  }

  /// Validates JSON file to check if all required keys are found
  ///
  /// Parameters: A json map and a list of strings with the required key names
  ///
  /// Returns [true] if valid, [false] if otherwise
  static void validateJson(
      Map<String, dynamic> json, List<String> requiredKeys) {
    for (var key in requiredKeys) {
      if (!json.containsKey(key)) {
        throw InvalidJsonException('Required key not found: $key');
      }
    }
  }
}
