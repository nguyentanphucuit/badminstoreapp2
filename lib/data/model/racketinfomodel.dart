import 'dart:convert';

class RacketInfoModel {
  int? id;
  int? productId;
  String? chatLieu;
  String? trongLuong;
  String? chuViCan;
  String? chieuDaiVot;
  String? chieuDaiCan;

  RacketInfoModel({this.id, this.productId, this.chatLieu, this.trongLuong, this.chuViCan, this.chieuDaiVot, this.chieuDaiCan});

  RacketInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    chatLieu = json['chatlieu'];
    trongLuong = json['trongluong'];
    chuViCan = json['chuvican'];
    chieuDaiVot = json['chieudaivot'];
    chieuDaiCan = json['chieudaican'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['chatlieu'] = chatLieu;
    data['trongluong'] = trongLuong;
    data['chuvican'] = chuViCan;
    data['chieudaivot'] = chieuDaiVot;
    data['chieudaican'] = chieuDaiCan;
    return data;
  }
}