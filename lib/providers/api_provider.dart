import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class ApiProvider<Item> extends ChangeNotifier {
  ApiProvider([this.items]);
  List<Item> items = [];
  Future<bool> fetch({
    http.Client client,
    Map<String, dynamic> params,
    String token,
  });

  Future<dynamic> post({
    Item item,
    http.Client client,
    String token,
  });
}
