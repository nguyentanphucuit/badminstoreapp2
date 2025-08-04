import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/brandmodel.dart';

class BrandData {
  Future<List<BrandModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/brandlist.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => BrandModel.fromJson(e))
        .toList();
  }
}