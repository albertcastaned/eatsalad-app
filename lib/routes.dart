import 'package:flutter/material.dart';

import 'screens/add_card_screen.dart';
import 'screens/address_setup_screen.dart';
import 'screens/card_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/items_screen.dart';
import 'screens/register_screen.dart';

// Screens

var routes = <String, WidgetBuilder>{
  RegisterScreen.routeName: (ctx) => RegisterScreen(),
  ItemsScreen.routeName: (ctx) => ItemsScreen(),
  CartScreen.routeName: (ctx) => CartScreen(),
  AddressSetupScreen.routeName: (ctx) => AddressSetupScreen(),
  AddCardScreen.routeName: (ctx) => AddCardScreen(),
  CardListScreen.routeName: (ctx) => CardListScreen(),
};
