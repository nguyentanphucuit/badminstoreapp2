import 'dart:convert';

class ProductSizeModel {
  int? id;
  int? productId;
  String? size;
  int? status;

  ProductSizeModel({this.id, this.productId, this.size, this.status});

  ProductSizeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    size = json['size'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['size'] = size;
    data['status'] = status;
    return data;
  }
}