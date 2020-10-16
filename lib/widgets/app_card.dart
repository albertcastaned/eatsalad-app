import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  AppCard({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }
}
