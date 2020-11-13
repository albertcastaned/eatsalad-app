import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../utils.dart';

class Category {
  int id;
  List<Item> items;
  String name;
  String image;
  bool active;

  Category({this.id, this.items, this.name, this.image, this.active});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['item_set'] != null) {
      items = new List<Item>();
      json['item_set'].forEach((v) {
        items.add(new Item.fromJson(v));
      });
    }
    name = json['name'];
    image = json['image'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.items != null) {
      data['item_set'] = this.items.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['image'] = this.image;
    data['active'] = this.active;
    return data;
  }
}

class Item {
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
    id = json['id'];
    if (json['amenities'] != null) {
      amenities = new List<Amenities>();
      json['amenities'].forEach((v) {
        amenities.add(new Amenities.fromJson(v));
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.amenities != null) {
      data['amenities'] = this.amenities.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['image'] = this.image;
    data['price'] = this.price;
    data['description'] = this.description;
    data['active'] = this.active;
    data['restaurant'] = this.restaurant;
    data['category'] = this.category;
    return data;
  }
}

class Amenities {
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
    fieldType = json['field_type'];
    minimumSelect = json['minimum_select'];
    maximumSelect = json['maximum_select'];
    obligatory = json['obligatory'];
    amenity =
        json['amenity'] != null ? new Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['field_type'] = this.fieldType;
    data['minimum_select'] = this.minimumSelect;
    data['maximum_select'] = this.maximumSelect;
    data['obligatory'] = this.obligatory;
    if (this.amenity != null) {
      data['amenity'] = this.amenity.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return amenity.name;
  }
}

class Amenity {
  int id;
  List<Ingredient> ingredients;
  String name;
  bool active;
  int restaurant;

  Amenity({this.id, this.ingredients, this.name, this.active, this.restaurant});

  Amenity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['ingredient_set'] != null) {
      ingredients = new List<Ingredient>();
      json['ingredient_set'].forEach((v) {
        ingredients.add(new Ingredient.fromJson(v));
      });
    }
    name = json['name'];
    active = json['active'];
    restaurant = json['restaurant'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.ingredients != null) {
      data['ingredient_set'] = this.ingredients.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['active'] = this.active;
    data['restaurant'] = this.restaurant;
    return data;
  }
}

class Ingredient {
  int id;
  String name;
  String price;

  Ingredient({this.id, this.name, this.price});

  Ingredient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }

  @override
  String toString() {
    return name;
  }
}

class CategoriesProvider extends ChangeNotifier {
  List<Category> categories;

  Future<void> fetchCategories(int restaurant) async {
    try {
      final apiUrl = "${Constants.server}/categories/?restaurant=$restaurant";
      String token = await FirebaseAuth.instance.currentUser.getIdToken();
      final response = await apiGet(apiUrl, requestApiHeaders(token))
          .timeout(Duration(seconds: Constants.timeoutSeconds));

      categories =
          (response as List).map((item) => Category.fromJson(item)).toList();
      return categories;
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }
}
