import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/slidermodel.dart';

class SliderData {
  Future<List<SliderModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/slider.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => SliderModel.fromJson(e))
        .toList();
  }
}