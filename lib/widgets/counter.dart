import 'package:flutter/material.dart';

class CounterListView extends StatefulWidget {
  CounterListView({
    @required this.title,
    @required this.onPressed,
    this.maxValue,
    Key key,
  }) : super(key: key);

  final String title;
  final int maxValue;
  final Function(int value) onPressed;

  @override
  _CounterListViewState createState() => _CounterListViewState();
}

class _CounterListViewState extends State<CounterListView> {
  int value;
  @override
  void initState() {
    value = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = 20.0;
    final double buttonSize = 30.0;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              MaterialButton(
                height: buttonSize,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Icon(
                  Icons.remove,
                  size: iconSize,
                ),
                elevation: 0.0,
                shape: CircleBorder(),
                onPressed: (value > 0)
                    ? () {
                        setState(() {
                          value -= 1;
                          widget.onPressed(value);
                        });
                      }
                    : null,
              ),
              Text(
                value.toString(),
              ),
              MaterialButton(
                height: buttonSize,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Icon(
                  Icons.add,
                  size: iconSize,
                ),
                elevation: 0.0,
                shape: CircleBorder(),
                onPressed: (widget.maxValue == null || value < widget.maxValue)
                    ? () {
                        setState(() {
                          value += 1;
                          widget.onPressed(value);
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
