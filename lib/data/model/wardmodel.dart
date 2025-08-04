import 'dart:convert';

class WardModel {
  int? id;
  int? idTinhThanh;
  String? tenPhuongXa;

  WardModel({this.id, this.idTinhThanh, this.tenPhuongXa});

  WardModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idTinhThanh = json['id_tinh_thanh'];
    tenPhuongXa = json['ten_phuong_xa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_tinh_thanh'] = idTinhThanh;
    data['ten_phuong_xa'] = tenPhuongXa;
    return data;
  }
}