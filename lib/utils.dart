import 'package:flushbar/flushbar.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import './constants.dart';

Flushbar flushBar;
void buildError(BuildContext context, String message,
    [String actionText, Function action]) {
  flushBar = Flushbar(
    messageText: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(seconds: 3),
    backgroundColor: Theme.of(context).errorColor,
    flushbarPosition: FlushbarPosition.TOP,
    mainButton: action != null
        ? FlatButton(
            onPressed: () {
              flushBar.dismiss(true);
              action();
            },
            child: Text(
              actionText,
              style: TextStyle(color: Colors.white),
            ),
          )
        : null,
  )..show(context);
}

Future<void> showSuccesfulDialog(String message, BuildContext context) {
  final deviceSize = MediaQuery.of(context).size;
  final textScaleFactor = deviceSize.height / 800;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(Constants.borderRadius),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: deviceSize.height / 8,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textScaleFactor * 16),
              ),
            ],
          ),
        ),
      );
    },
  );
}

ProgressDialog buildLoadingDialog(BuildContext context, String message) {
  ProgressDialog dialog = new ProgressDialog(
    context,
    isDismissible: false,
  );

  dialog.style(
    message: message,
    borderRadius: Constants.borderRadius,
    progressWidget: CircularProgressIndicator(),
    progressTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 9.0,
    ),
    messageTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 13.0,
    ),
  );

  return dialog;
}

Future<Map<String, dynamic>> apiPost(String apiUrl, Map<String, dynamic> body,
    Map<String, String> headers) async {
  print("POST $apiUrl \n\n Headers: $headers \n\n Body: $body \n\n ");
  try {
    final apiResponse = await http
        .post(
          apiUrl,
          headers: headers,
          body: json.encode(body),
        )
        .timeout(Duration(seconds: Constants.timeoutSeconds));
    final apiResponseData = json.decode(apiResponse.body);
    print(apiResponseData);
    if (apiResponse.statusCode >= 400) {
      throw HttpException(apiResponseData.toString());
    }
    return json.decode(apiResponse.body);
  } catch (error) {
    print(error);
    return null;
  }
}

Future<Map<String, dynamic>> apiGet(
    String apiUrl, Map<String, String> headers) async {
  print("POST $apiUrl \n\n Headers: $headers \n\n");

  try {
    final apiResponse = await http
        .get(
          apiUrl,
          headers: headers,
        )
        .timeout(Duration(seconds: Constants.timeoutSeconds));
    final apiResponseData = json.decode(apiResponse.body);
    print(apiResponseData);

    if (apiResponse.statusCode >= 400) {
      throw HttpException(apiResponseData.toString());
    }
    return json.decode(apiResponse.body);
  } catch (error) {
    print(error);
    return null;
  }
}

Map<String, String> requestApiHeaders(String token) {
  return {
    "Content-Type": "application/json",
    "Authorization": "JWT " + token,
  };
}
