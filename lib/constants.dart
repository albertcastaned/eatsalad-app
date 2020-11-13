import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static get server {
    if (DotEnv().env['USE_HTTPS'] != null)
      return "https://${DotEnv().env['HOST']}";
    else
      return "http://${DotEnv().env['HOST']}";
  }

  static get googleApiKey {
    return DotEnv().env['GOOGLE_API_KEY'];
  }

  static get timeoutSeconds {
    return 10;
  }

  static get borderRadius {
    return 15.0;
  }

  static get bodyMargin {
    return EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  }
}

class Error {
  static const EMPTY_FIELDS = "Este campo no puede estar vacio.";
  static const INVALID_ACCOUNT = "Correo o contraseña incorrecta.";
  static const UNKNOWN_ERROR = "Ocurrio un error al intentar autenticarte.";
  static const INVALID_EMAIL = "Este campo debe tener un correo valido.";
  static const CONNECTION_ERROR = "Ocurrió un error de conexión.";
  static const PASSWORD_UNMATCH =
      "La contraseña no coincide con la de confirmacion.";
  static const SHORT_PASSWORD = "La contraseña debe tener mas de 6 caracteres.";
}
