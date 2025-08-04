import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/intromodel.dart';

class IntroData {
  Future<List<IntroModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/intro.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => IntroModel.fromJson(e))
        .toList();
  }
}