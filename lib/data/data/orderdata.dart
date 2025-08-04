import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/ordermodel.dart';

class OrderData {
  Future<List<OrderModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/orderlist.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }
}