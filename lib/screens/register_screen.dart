import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/auth.dart';
import '../utils/dialog_utils.dart';

import '../widgets/app_body.dart';
import '../widgets/app_card.dart';

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

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'confirmPassword': '',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    final progressDialog = buildLoadingDialog(
      context,
      'Registrando usuario...',
    );
    progressDialog.show();

    try {
      final success = await Provider.of<Auth>(context, listen: false)
          .signUpEmailPassword(_authData['email'], _authData['password']);
      progressDialog.hide();

      if (success) {
        Navigator.of(context).pop();
      }
    } on PlatformException catch (error) {
      final errorMessage = Errors.userNotFound;
      print(error);
      progressDialog.hide();

      buildFlashBar(context, errorMessage);
    } catch (error) {
      final errorMessage = Errors.connectionError;
      print(error);
      progressDialog.hide();

      buildFlashBar(
        context,
        errorMessage,
        actionText: 'Reintentar',
        action: _submit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      title: 'Registrar usuario',
      child: Center(
        child: AppCard(
          child: Container(
            padding: bodyPadding,
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/logo.jpeg'),
                    height: 150,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      suffixIcon: Icon(Icons.mail),
                    ),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return Errors.emptyField;
                      } else if (!value.contains('@')) {
                        return Errors.invalidEmail;
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
                        return Errors.emptyField;
                      } else if (value != _confirmPasswordController.text) {
                        return Errors.passwordUnmatch;
                      } else if (value.length < 6) {
                        return Errors.weakPassword;
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
                        return Errors.emptyField;
                      } else if (value != _passwordController.text) {
                        return Errors.passwordUnmatch;
                      } else if (value.length < 6) {
                        return Errors.weakPassword;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['confirmPassword'] = value;
                    },
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Ya tienes cuenta? Ingresa sesion',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: RaisedButton(
                      child: Text(
                        'Registrarme',
                      ),
                      onPressed: _submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70.0, vertical: 8.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
