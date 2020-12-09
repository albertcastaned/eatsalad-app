import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/auth.dart';
import '../utils.dart';
import '../widgets/app_body.dart';
import '../widgets/app_card.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    Future<void> _signInWithGoogle() async {
      try {
        await Provider.of<Auth>(context, listen: false)
            .authenticateWithGoogle(context);
      } on TimeoutException catch (error) {
        print(error);
        buildError(context, Error.CONNECTION_ERROR);
      } catch (error) {
        print(error);
      }
    }

    return AppBody(
      child: SingleChildScrollView(
        child: Center(
          child: AppCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/logo.jpeg')),
                  LoginForm(),
                  Container(
                    child: Wrap(
                      children: <Widget>[
                        Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(
                            fontSize: 11,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(RegisterScreen.routeName);
                          },
                          child: Text(
                            'Regístrate aquí',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              decoration: TextDecoration.underline,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      child: Text('Iniciar con Google'),
                      onPressed: () => _signInWithGoogle(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  @override
  void initState() {
    //TODO: Remove this placeholder
    _emailController.text = "test5@gmail.com";
    _passwordController.text = "Blaster64\$";

    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    try {
      await Provider.of<Auth>(context, listen: false)
          .signInWithEmail(context, _authData['email'], _authData['password']);
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
    return Form(
      key: _formKey,
      child: Column(
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
              }
              return null;
            },
            onSaved: (value) {
              _authData['password'] = value;
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {},
              child: Text(
                'Olvidé mi contraseña',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).accentColor,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(0, 25, 0, 10),
            child: RaisedButton(
              child: Text(
                'Iniciar sesión',
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
    );
  }
}
