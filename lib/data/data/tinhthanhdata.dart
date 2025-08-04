import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/provincemodel.dart';

class TinhThanhData {
  Future<List<ProvinceModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/tinh_thanh.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => ProvinceModel.fromJson(e))
        .toList();
  }
}