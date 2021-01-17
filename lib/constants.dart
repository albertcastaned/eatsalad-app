import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

get server {
  if (isTesting) {
    return 'test-url';
  } else if (DotEnv().env['USE_HTTPS'] != null) {
    return "https://${DotEnv().env['HOST']}";
  } else {
    return "http://${DotEnv().env['HOST']}";
  }
}

get stripeSecretKey {
  return DotEnv().env['STRIPE_SECRET_KEY'];
}

get stripePublicKey {
  return DotEnv().env['STRIPE_KEY'];
}

get googleApiKey {
  return DotEnv().env['GOOGLE_API_KEY'];
}

const timeoutSeconds = 10;

const borderRadius = 15.0;

const bodyPadding = EdgeInsets.all(15);

const bodyMargin = EdgeInsets.symmetric(horizontal: 20, vertical: 20);

final isTesting = Platform.environment.containsKey('FLUTTER_TEST');

class Errors {
  static const emptyField = "Este campo no puede estar vacio.";
  static const userNotFound = "Correo o contraseña incorrecta.";
  static const unknownError = "Ocurrio un error al intentar autenticarte.";
  static const invalidEmail = "Este campo debe tener un correo valido.";
  static const connectionError = "Ocurrió un error de conexión.";
  static const passwordUnmatch =
      "La contraseña no coincide con la de confirmacion.";
  static const weakPassword = "La contraseña debe tener mas de 6 caracteres.";
  static const existingUser =
      "Existe un usuario registrado con el mismo correo."
      " Intente otro correo electronico";
  static const stripeTransactionError = 'Ocurrio un error al procesar '
      'la tarjeta. Valide los datos de nuevo.';
  static const invalidPaymentMethod = "Metodo de pago invalido. "
      "Intente de nuevo o con otro metodo";
}
