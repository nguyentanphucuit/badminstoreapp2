import 'dart:convert';

class ProductModel {
  int? id;
  String? code;
  String? productName;
  int? categoryId;
  int? brandId;
  int? cost;
  int? priceSale;
  String? image;
  int? status;
  int? visible;

  ProductModel({
    this.id,
    this.code,
    this.productName,
    this.categoryId,
    this.brandId,
    this.cost,
    this.priceSale,
    this.image,
    this.status,
    this.visible,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    productName = json['productname'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    cost = json['cost'];
    priceSale = json['pricesale'];
    image = json['image'];
    status = json['status'];
    visible = json['visible'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['productname'] = productName;
    data['category_id'] = categoryId;
    data['brand_id'] = brandId;
    data['cost'] = cost;
    data['pricesale'] = priceSale;
    data['image'] = image;
    data['status'] = status;
    data['visible'] = visible;
    return data;
  }
}