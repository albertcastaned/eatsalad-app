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
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
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
}

class CategoriesProvider extends ChangeNotifier {
  List<Category> categories;

  Future<void> fetchCategories(int restaurant) async {
    try {
      final apiUrl = "$server/categories/?restaurant=$restaurant";
      var token = await FirebaseAuth.instance.currentUser.getIdToken();
      final response = await apiGet(apiUrl, requestApiHeaders(token))
          .timeout(Duration(seconds: timeoutSeconds));

      categories =
          (response as List).map((item) => Category.fromJson(item)).toList();
      categories = categories.where((i) => i.items.isNotEmpty).toList();
      return categories;
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }
}
