import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  final String text;
  final Function onReduced;
  final Function onAdded;

  Counter(
      {@required this.text, @required this.onAdded, @required this.onReduced});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          padding: EdgeInsets.all(0),
          minWidth: 0,
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Icon(
            Icons.remove,
          ),
          shape: CircleBorder(),
          onPressed: onReduced,
        ),
        Text(
          text,
        ),
        MaterialButton(
          padding: EdgeInsets.all(0),
          minWidth: 0,
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Icon(
            Icons.add,
          ),
          shape: CircleBorder(),
          onPressed: onAdded,
        ),
      ],
    );
  }
}
