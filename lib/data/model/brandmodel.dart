import 'dart:convert';

class BrandModel {
  int? id;
  String? brandName;

  BrandModel({this.id, this.brandName});

  BrandModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    brandName = json['brandname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['brandname'] = brandName;
    return data;
  }
}