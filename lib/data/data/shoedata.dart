import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/shoeinfomodel.dart';

class ShoeData {
  Future<List<ShoeInfoModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/shoe_info.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => ShoeInfoModel.fromJson(e))
        .toList();
  }
}