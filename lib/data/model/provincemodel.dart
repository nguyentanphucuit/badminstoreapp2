import 'dart:convert';

class ProvinceModel {
  int? id;
  String? tenTinhThanh;

  ProvinceModel({this.id, this.tenTinhThanh});

  ProvinceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tenTinhThanh = json['ten_tinh_thanh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ten_tinh_thanh'] = tenTinhThanh;
    return data;
  }
}