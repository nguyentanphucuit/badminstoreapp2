import 'dart:convert';

class CategoryModel {
  int? id;
  String? categoryName;
  String? image;

  CategoryModel({this.id, this.categoryName, this.image});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryname'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['categoryname'] = categoryName;
    data['image'] = image;
    return data;
  }
}