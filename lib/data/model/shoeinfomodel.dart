import 'dart:convert';

class ShoeInfoModel {
  int? id;
  int? productId;
  String? size;
  String? thanGiay;
  String? deGiua;
  String? deNgoai;
  String? benTrong;

  ShoeInfoModel({this.id, this.productId, this.size, this.thanGiay, this.deGiua, this.deNgoai, this.benTrong});

  ShoeInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    size = json['size'];
    thanGiay = json['thangiay'];
    deGiua = json['demigiua'];
    deNgoai = json['de_ngoai'];
    benTrong = json['ben_trong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['size'] = size;
    data['thangiay'] = thanGiay;
    data['demigiua'] = deGiua;
    data['de_ngoai'] = deNgoai;
    data['ben_trong'] = benTrong;
    return data;
  }
}