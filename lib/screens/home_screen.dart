import 'package:flutter/material.dart';

import '../widgets/app_body.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'restaurants_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _navScreens = <Widget>[
    RestaurantsScreen(),
    HistoryScreen(),
    ProfileScreen()
  ];
  static final List<String> _navScreensTitles = <String>[
    'Sucursales',
    'Mis Pedidos',
    'Mi Perfil'
  ];

  void _onBottomNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBody(
      title: _navScreensTitles[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: _navScreensTitles[0]),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: _navScreensTitles[1]),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: _navScreensTitles[2]),
        ],
        currentIndex: _selectedIndex,
        onTap: _onBottomNavBarTapped,
      ),
      child: _navScreens[_selectedIndex],
    );
  }
}
