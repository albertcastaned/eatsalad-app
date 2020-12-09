import 'dart:math';

import 'package:flushbar/flushbar.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import 'package:strings/strings.dart';

import 'constants.dart';

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

Future<dynamic> apiPost(String apiUrl, Map<String, dynamic> body,
    Map<String, String> headers) async {
  print("POST $apiUrl \n\n Body: $body \n\n ");
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

Future<dynamic> apiGet(String apiUrl, Map<String, String> headers) async {
  print("POST $apiUrl \n\n");

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

double distanceBetweenPoints(double x1, double y1, double x2, double y2) {
  return sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2));
}

class CardUtils {
  static String validateDate(String value) {
    int year;
    int month;
    if (value.contains(new RegExp(r'(\/)'))) {
      var split = value.split(new RegExp(r'(\/)'));
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      month = int.parse(value.substring(0, (value.length)));
      year = -1;
    }

    if ((month < 1) || (month > 12)) {
      return 'El mes de expiracion es invalido.';
    }

    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      return 'El año de expiracion es invalido.';
    }

    if (!hasDateExpired(month, year)) {
      return "La tarjeta esta expirada";
    }
    return null;
  }

  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static bool hasDateExpired(int month, int year) {
    return !(month == null || year == null) && isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();

    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();

    return fourDigitsYear < now.year;
  }

  static String validateCVV(String value) {
    if (value.length < 3 || value.length > 4) {
      return "CVC es invalido";
    }
    return null;
  }

  static String getCleanedNumber(String number) {
    return number.replaceAll(new RegExp(r'[^0-9]+'), '');
  }

  static bool isCreditCard(String str) {
    String sanitized = str.replaceAll(new RegExp(r'[^0-9]+'), '');

    // Luhn algorithm
    int sum = 0;
    String digit;
    bool shouldDouble = false;

    for (int i = sanitized.length - 1; i >= 0; i--) {
      digit = sanitized.substring(i, (i + 1));
      int tmpNum = int.parse(digit);

      if (shouldDouble == true) {
        tmpNum *= 2;
        if (tmpNum >= 10) {
          sum += ((tmpNum % 10) + 1);
        } else {
          sum += tmpNum;
        }
      } else {
        sum += tmpNum;
      }
      shouldDouble = !shouldDouble;
    }

    return (sum % 10 == 0);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => capitalize(str)).join(" ");
}

Widget getCardTypeIcon(String cardType) {
  Widget icon;
  switch (cardType) {
    case "visa":
      icon = Image.asset(
        'icons/visa.png',
        height: 48,
        width: 48,
        package: 'flutter_credit_card',
      );
      break;

    case "amex":
      icon = Image.asset(
        'icons/amex.png',
        height: 48,
        width: 48,
        package: 'flutter_credit_card',
      );
      break;

    case "mastercard":
      icon = Image.asset(
        'icons/mastercard.png',
        height: 48,
        width: 48,
        package: 'flutter_credit_card',
      );
      break;

    case "discover":
      icon = Image.asset(
        'icons/discover.png',
        height: 48,
        width: 48,
        package: 'flutter_credit_card',
      );
      break;

    default:
      icon = Container(
        height: 48,
        width: 48,
      );
      break;
  }

  return icon;
}
