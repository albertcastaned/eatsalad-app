import 'package:EatSalad/widgets/app_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../providers/auth.dart';
import '../utils.dart';
import '../constants.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = "/register";
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'confirmPassword': '',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    try {
      await Provider.of<Auth>(context, listen: false).signUpEmailPassword(
          context, _authData['email'], _authData['password']);
    } on PlatformException catch (error) {
      final errorMessage = Error.INVALID_ACCOUNT;
      print(error);
      buildError(context, errorMessage);
    } catch (error) {
      final errorMessage = Error.CONNECTION_ERROR;
      print(error);
      buildError(context, errorMessage, 'Reintentar', _submit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                suffixIcon: Icon(Icons.mail),
              ),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value.isEmpty) {
                  return Error.EMPTY_FIELDS;
                } else if (!value.contains('@')) {
                  return Error.INVALID_EMAIL;
                }
                return null;
              },
              onSaved: (value) {
                _authData['email'] = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: Icon(Icons.vpn_key),
              ),
              obscureText: true,
              controller: _passwordController,
              validator: (value) {
                if (value.isEmpty) {
                  return Error.EMPTY_FIELDS;
                } else if (value != _confirmPasswordController.text) {
                  return Error.PASSWORD_UNMATCH;
                } else if (value.length < 6) {
                  return Error.SHORT_PASSWORD;
                }
                return null;
              },
              onSaved: (value) {
                _authData['password'] = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                suffixIcon: Icon(Icons.vpn_key),
              ),
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (value) {
                if (value.isEmpty) {
                  return Error.EMPTY_FIELDS;
                } else if (value != _passwordController.text) {
                  return Error.PASSWORD_UNMATCH;
                } else if (value.length < 6) {
                  return Error.SHORT_PASSWORD;
                }
                return null;
              },
              onSaved: (value) {
                _authData['confirmPassword'] = value;
              },
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 25, 0, 10),
              child: RaisedButton(
                child: Text(
                  'Registrarme',
                ),
                onPressed: _submit,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 70.0, vertical: 8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
