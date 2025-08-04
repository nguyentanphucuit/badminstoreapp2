import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/categorymodel.dart';

class CategoryData {
  Future<List<CategoryModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/categorylist.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }
}