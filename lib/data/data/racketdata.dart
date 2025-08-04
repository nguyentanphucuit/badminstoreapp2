import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/racketinfomodel.dart';

class RacketData {
  Future<List<RacketInfoModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/racket_info.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => RacketInfoModel.fromJson(e))
        .toList();
  }
}