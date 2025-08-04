import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/orderdetailmodel.dart';

class OrderDetailData {
  Future<List<OrderDetailModel>> loadData() async {
    var data = await rootBundle.loadString("assets/files/orderdetaillist.json");
    var dataJson = jsonDecode(data);

    return (dataJson['data'] as List)
        .map((e) => OrderDetailModelWithName.fromJson(e))
        .toList();
  }
}

/*
// Extended model to include product name
class OrderDetailModelWithProductName extends OrderDetailModel {
  String? productName;
  String? Size;
  
  OrderDetailModelWithProductName({
    super.id,
    super.orderId,
    super.productId,
    this.Size,
    super.quantity,
    super.price,
    super.totalPrice,
    this.productName,
  });

  factory OrderDetailModelWithProductName.fromJson(Map<String, dynamic> json) {
    return OrderDetailModelWithProductName(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      Size: json['size'],
      quantity: json['quantity'],
      price: json['unit_price'], // Note: using unit_price from JSON
      totalPrice: json['total_price'],
      productName: json['product_name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['product_name'] = productName;
    return data;
  }
}*/