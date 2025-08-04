import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/wardmodel.dart';

class PhuongXaData {
  Future<List<WardModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/phuong_xa.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => WardModel.fromJson(e))
        .toList();
  }
}