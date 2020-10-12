import 'package:flutter/material.dart';

class AppBody extends StatelessWidget {
  final Widget child;

  AppBody({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
