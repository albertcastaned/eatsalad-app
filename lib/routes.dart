import 'package:flutter/material.dart';

import 'screens/AddressSetupScreen.dart';
import 'screens/CartScreen.dart';
import 'screens/ItemsScreen.dart';
import 'screens/RegisterScreen.dart';
// Screens

var routes = <String, WidgetBuilder>{
  RegisterScreen.routeName: (ctx) => RegisterScreen(),
  ItemsScreen.routeName: (ctx) => ItemsScreen(),
  CartScreen.routeName: (ctx) => CartScreen(),
  AddressSetupScreen.routeName: (ctx) => AddressSetupScreen(),
};
