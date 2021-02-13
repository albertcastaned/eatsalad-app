import 'package:flutter/material.dart';
import '../constants.dart';

class AppBody extends StatelessWidget {
  final Widget child;
  final String title;
  final bool isFullScreen;
  final BottomNavigationBar bottomNavigationBar;
  AppBody({
    @required this.child,
    this.title,
    this.bottomNavigationBar,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title),
            ),
      bottomNavigationBar: bottomNavigationBar,
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
                    padding: bodyPadding,
                    child: child,
                  ),
                ],
              ),
            ),
    );
  }
}
