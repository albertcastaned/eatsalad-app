import 'package:flutter/material.dart';

class ValueContainer extends StatelessWidget {
  final String content;
  ValueContainer({this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xff2d9649),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        content,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
