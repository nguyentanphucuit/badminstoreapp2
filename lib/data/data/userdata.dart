import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/usermodel.dart';

class UserData {
  Future<List<UserModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/user.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }
}