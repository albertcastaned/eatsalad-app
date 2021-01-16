import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/auth.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_body.dart';
import '../widgets/app_card.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    Future<void> _signInWithGoogle() async {
      try {
        final userCredentials = await Provider.of<Auth>(context, listen: false)
            .authenticateWithGoogle();
        await Provider.of<Auth>(context, listen: false)
            .authenticate(userCredentials);
      } on TimeoutException catch (error) {
        print(error);
        buildError(context, Errors.connectionError);
      } catch (error) {
        print(error);
      }
    }

    return AppBody(
      title: 'Iniciar sesion',
      child: Center(
        child: AppCard(
          child: Container(
            padding: bodyPadding,
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
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                  child: OutlineButton(
                    splashColor: Colors.grey,
                    onPressed: _signInWithGoogle,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    highlightElevation: 0,
                    borderSide: BorderSide(color: Colors.grey),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/google_logo.png"),
                            height: 35.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Iniciar sesion con Google',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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

  final Map<String, String> _authData = {
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
      final userCredentials = await Provider.of<Auth>(context, listen: false)
          .signInWithEmail(_authData['email'], _authData['password']);
      await Provider.of<Auth>(context, listen: false)
          .authenticate(userCredentials);
    } on PlatformException catch (error) {
      final errorMessage = Errors.userNotFound;
      print(error);
      buildError(context, errorMessage);
    } on TimeoutException catch (error) {
      final errorMessage = Errors.connectionError;
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
            margin: const EdgeInsets.symmetric(vertical: 25),
            width: double.infinity,
            child: RaisedButton(
              padding: const EdgeInsets.all(15),
              onPressed: _submit,
              child: Text(
                'Iniciar sesion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
