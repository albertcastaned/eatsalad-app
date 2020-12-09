import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  final String text;
  AppTitle({@required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
