import 'package:flutter/material.dart';

class CardUtils {
  static String validDate(String value) {
    if (value.isEmpty) return 'Este campo no debe estar vacio.';
    if (value.length != 5) return 'Este campo debe tener 5 caracteres.';

    int year;
    int month;
    if (value.contains(RegExp(r'(\/)'))) {
      var split = value.split(RegExp(r'(\/)'));
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
      var currentYear = now.year.toString();
      var prefix = currentYear.substring(0, currentYear.length - 2);
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
    var fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();

    return fourDigitsYear < now.year;
  }

  static bool validCVV(String value) {
    return !(value.length < 3 || value.length > 4);
  }

  static String getCleanedNumber(String number) {
    return number.replaceAll(RegExp(r'[^0-9]+'), '');
  }

  static bool validCreditCard(String str) {
    const maxDigits = 19;
    const minDigits = 12;

    if (str.isEmpty) return false;
    if (str.length < minDigits || str.length > maxDigits) return false;

    var sanitized = str.replaceAll(RegExp(r'[^0-9]+'), '');

    // Luhn algorithm
    var sum = 0;
    String digit;
    var shouldDouble = false;

    for (var i = sanitized.length - 1; i >= 0; i--) {
      digit = sanitized.substring(i, (i + 1));
      var tmpNum = int.parse(digit);

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
    var split = value.split(RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static Widget getCardTypeIcon(String cardType) {
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
}
