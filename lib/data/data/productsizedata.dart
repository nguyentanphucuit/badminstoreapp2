import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/productsizemodel.dart';

class ProductSizeData {
  Future<List<ProductSizeModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/productsizelist.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => ProductSizeModel.fromJson(e))
        .toList();
  }
}