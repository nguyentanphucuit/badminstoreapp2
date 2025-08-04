import 'dart:convert';

class ClothingInfoModel {
  int? id;
  int? productId;
  String? size;
  String? chatLieu;
  String? thietKe;
  String? kieuLoai;
  String? tinhNang;

  ClothingInfoModel({this.id, this.productId, this.size, this.chatLieu, this.thietKe, this.kieuLoai, this.tinhNang});

  ClothingInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    size = json['size'];
    chatLieu = json['chatlieu'];
    thietKe = json['thietke'];
    kieuLoai = json['kieuloai'];
    tinhNang = json['tinhnang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['size'] = size;
    data['chatlieu'] = chatLieu;
    data['thietke'] = thietKe;
    data['kieuloai'] = kieuLoai;
    data['tinhnang'] = tinhNang;
    return data;
  }
}