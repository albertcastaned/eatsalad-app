import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../exceptions/invalid_json_exception.dart';
import '../utils/api_utils.dart';
import 'api_provider.dart';
import 'base_model.dart';

class Category implements BaseModel {
  int id;
  List<Item> items;
  String name;
  String image;
  bool active;

  Category({this.id, this.items, this.name, this.image, this.active});

  Category.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);
    id = json['id'];
    if (json['item_set'] != null) {
      items = <Item>[];
      json['item_set'].forEach((v) {
        items.add(Item.fromJson(v));
      });
    }
    name = json['name'];
    image = json['image'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    if (items != null) {
      data['item_set'] = items.map((v) => v.toJson()).toList();
    }
    data['name'] = name;
    data['image'] = image;
    data['active'] = active;
    return data;
  }

  @override
  List<String> requiredKeys = [
    'id',
    'item_set',
    'name',
    'image',
    'active',
  ];
}

class Item implements BaseModel {
  int id;
  List<Amenities> amenities;
  String name;
  String image;
  String price;
  String description;
  bool active;
  int restaurant;
  int category;

  Item(
      {this.id,
      this.amenities,
      this.name,
      this.image,
      this.price,
      this.description,
      this.active,
      this.restaurant,
      this.category});

  Item.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);

    id = json['id'];
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities.add(Amenities.fromJson(v));
      });
    }
    name = json['name'];
    image = json['image'];
    price = json['price'];
    description = json['description'];
    active = json['active'];
    restaurant = json['restaurant'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    if (amenities != null) {
      data['amenities'] = amenities.map((v) => v.toJson()).toList();
    }
    data['name'] = name;
    data['image'] = image;
    data['price'] = price;
    data['description'] = description;
    data['active'] = active;
    data['restaurant'] = restaurant;
    data['category'] = category;
    return data;
  }

  @override
  List<String> requiredKeys = [
    'id',
    'amenities',
    'name',
    'image',
    'price',
    'description',
    'active',
    'category'
  ];
}

class Amenities implements BaseModel {
  String fieldType;
  int minimumSelect;
  int maximumSelect;
  bool obligatory;
  Amenity amenity;

  Amenities(
      {this.fieldType,
      this.minimumSelect,
      this.maximumSelect,
      this.obligatory,
      this.amenity});

  Amenities.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);

    fieldType = json['field_type'];
    minimumSelect = json['minimum_select'];
    maximumSelect = json['maximum_select'];
    obligatory = json['obligatory'];
    amenity = Amenity.fromJson(json['amenity']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['field_type'] = fieldType;
    data['minimum_select'] = minimumSelect;
    data['maximum_select'] = maximumSelect;
    data['obligatory'] = obligatory;
    if (amenity != null) {
      data['amenity'] = amenity.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return amenity.name;
  }

  @override
  List<String> requiredKeys = [
    'field_type',
    'minimum_select',
    'maximum_select',
    'obligatory',
    'amenity'
  ];
}

class Amenity implements BaseModel {
  int id;
  List<Ingredient> ingredients;
  String name;
  bool active;
  int restaurant;

  Amenity({this.id, this.ingredients, this.name, this.active, this.restaurant});

  Amenity.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);

    id = json['id'];
    if (json['ingredient_set'] != null) {
      ingredients = <Ingredient>[];
      json['ingredient_set'].forEach((v) {
        ingredients.add(Ingredient.fromJson(v));
      });
    }
    name = json['name'];
    active = json['active'];
    restaurant = json['restaurant'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    if (ingredients != null) {
      data['ingredient_set'] = ingredients.map((v) => v.toJson()).toList();
    }
    data['name'] = name;
    data['active'] = active;
    data['restaurant'] = restaurant;
    return data;
  }

  @override
  List<String> requiredKeys = ['id', 'ingredient_set', 'name', 'active'];
}

class Ingredient implements BaseModel {
  int id;
  String name;
  String price;

  Ingredient({this.id, this.name, this.price});

  Ingredient.fromJson(Map<String, dynamic> json) {
    ApiHandler.validateJson(json, requiredKeys);

    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    return data;
  }

  @override
  String toString() {
    return name;
  }

  @override
  List<String> requiredKeys = [
    'id',
    'name',
    'price',
  ];
}

class CategoriesProvider extends ApiProvider<Category> {
  CategoriesProvider([List<Category> items]) : super(items);

  @override
  Future<bool> fetch({
    http.Client client,
    Map<String, dynamic> params,
    String token,
  }) async {
    try {
      if (params == null || params['restaurant'] == null) {
        print("'restaurant' param is required.");
        return false;
      }
      if (token == null) {
        token = await FirebaseAuth.instance.currentUser.getIdToken();
      }
      final url = "$server/categories/?restaurant=${params['restaurant']}]}";

      final response = await ApiHandler.request(
        method: HTTP_METHOD.get,
        url: url,
        token: token,
        client: client,
      );
      items =
          (response as List).map((item) => Category.fromJson(item)).toList();
      return true;
    } on TimeoutException {
      rethrow;
    } on HttpException {
      rethrow;
    } on InvalidJsonException {
      rethrow;
    }
  }

  @override
  Future post({
    item,
    http.Client client,
    String token,
  }) async {
    throw UnimplementedError();
  }
}
