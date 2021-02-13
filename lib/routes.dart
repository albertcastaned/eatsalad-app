import 'package:EatSalad/screens/home_screen.dart';
import 'package:EatSalad/screens/profile_setup_screen.dart';
import 'package:flutter/material.dart';

import 'screens/add_card_screen.dart';
import 'screens/address_setup_screen.dart';
import 'screens/card_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/items_screen.dart';
import 'screens/register_screen.dart';

// Screens

var routes = <String, WidgetBuilder>{
  HomeScreen.routeName: (ctx) => HomeScreen(),
  RegisterScreen.routeName: (ctx) => RegisterScreen(),
  ItemsScreen.routeName: (ctx) => ItemsScreen(),
  CartScreen.routeName: (ctx) => CartScreen(),
  AddressSetupScreen.routeName: (ctx) => AddressSetupScreen(),
  AddCardScreen.routeName: (ctx) => AddCardScreen(),
  CardListScreen.routeName: (ctx) => CardListScreen(),
  ProfileConfigScreen.routeName: (ctx) => ProfileConfigScreen(),
};
