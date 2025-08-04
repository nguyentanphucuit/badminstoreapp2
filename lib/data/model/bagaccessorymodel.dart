import 'dart:convert';

class BagAccessoryModel {
  int? id;
  int? productId;
  String? thuongHieu;
  String? mauSac;
  String? kichThuoc;
  String? chatLieu;
  String? tinhNang;

  BagAccessoryModel({this.id, this.productId, this.thuongHieu, this.mauSac, this.kichThuoc, this.chatLieu, this.tinhNang});

  BagAccessoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    thuongHieu = json['thuonghieu'];
    mauSac = json['mausac'];
    kichThuoc = json['kichthuoc'];
    chatLieu = json['chatlieu'];
    tinhNang = json['tinhnang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['thuonghieu'] = thuongHieu;
    data['mausac'] = mauSac;
    data['kichthuoc'] = kichThuoc;
    data['chatlieu'] = chatLieu;
    data['tinhnang'] = tinhNang;
    return data;
  }
}