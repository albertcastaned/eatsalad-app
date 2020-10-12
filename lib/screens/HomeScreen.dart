import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      await Provider.of<Auth>(context, listen: false).logout();
    }

    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Home Screen'),
              RaisedButton(
                child: Text('Cerrar sesion'),
                onPressed: logout,
              )
            ],
          ),
        ),
      ),
    );
  }
}
