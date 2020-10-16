import 'package:EatSalad/screens/ItemsScreen.dart';
import 'package:EatSalad/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';

// Screens

var routes = <String, WidgetBuilder>{
  RegisterScreen.routeName: (ctx) => RegisterScreen(),
  ItemsScreen.routeName: (ctx) => ItemsScreen(),
};
