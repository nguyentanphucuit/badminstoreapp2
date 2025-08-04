import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/clothinginfomodel.dart';

class ClothingData {
  Future<List<ClothingInfoModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/clothing_info.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => ClothingInfoModel.fromJson(e))
        .toList();
  }
}