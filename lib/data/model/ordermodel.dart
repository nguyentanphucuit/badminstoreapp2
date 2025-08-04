import 'dart:convert';

class OrderModel {
  int? id;
  int? userId;
  String? orderDate;
  String? receiverName;
  String? receiverPhone;
  String? shippingAddress;
  int? totalAmount;
  int? isPayment;
  int? orderStatus;

  OrderModel({
    this.id,
    this.userId,
    this.orderDate,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
    this.totalAmount,
    this.isPayment,
    this.orderStatus,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderDate = json['order_date'];
    receiverName = json['receiver_name'];
    receiverPhone = json['receiver_phone'];
    shippingAddress = json['shipping_address'];
    totalAmount = json['total_amount'];
    isPayment = json['is_payment'];
    orderStatus = json['order_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_date'] = orderDate;
    data['receiver_name'] = receiverName;
    data['receiver_phone'] = receiverPhone;
    data['shipping_address'] = shippingAddress;
    data['total_amount'] = totalAmount;
    data['is_payment'] = isPayment;
    data['order_status'] = orderStatus;
    return data;
  }
}