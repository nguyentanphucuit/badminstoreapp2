import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/bagaccessorymodel.dart';

class BagAccessoryData {
  Future<List<BagAccessoryModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/bagaccessory_info.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => BagAccessoryModel.fromJson(e))
        .toList();
  }
}