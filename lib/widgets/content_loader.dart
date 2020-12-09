import 'package:flutter/material.dart';

class ContentLoader extends StatelessWidget {
  final Future<void> future;
  final Widget widget;
  ContentLoader({
    @required this.future,
    @required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        } else {
          if (snapshot.hasError) {
            return Center(
              child: Text("Connection error"),
            );
          } else {
            return widget;
          }
        }
      },
    );
  }
}
