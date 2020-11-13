import 'package:flutter/material.dart';

class AppBody extends StatelessWidget {
  final Widget child;
  final Widget title;
  final bool isFullScreen;
  final AppBar appBar;
  AppBody(
      {@required this.child,
      this.title,
      this.isFullScreen = false,
      this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? null,
      resizeToAvoidBottomInset: true,
      body: isFullScreen
          ? SafeArea(
              child: Container(
                child: child,
              ),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Color(0xff00b248)
                          ]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: child,
                  ),
                ],
              ),
            ),
    );
  }
}
