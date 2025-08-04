import 'dart:convert';

class OrderDetailModel {
  int? id;
  int? orderId;
  int? productId;
  int? quantity;
  int? price;
  int? totalPrice;

  OrderDetailModel({this.id, this.orderId, this.productId, this.quantity, this.price, this.totalPrice});

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['total_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['price'] = price;
    data['total_price'] = totalPrice;
    return data;
  }
}

class OrderDetailModelWithName extends OrderDetailModel {
  String? productName;
  String? Size;
  
  OrderDetailModelWithName({
    super.id,
    super.orderId,
    super.productId,
    this.Size,
    super.quantity,
    super.price,
    super.totalPrice,
    this.productName,
  });

  factory OrderDetailModelWithName.fromJson(Map<String, dynamic> json) {
    return OrderDetailModelWithName(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      Size: json['size'],
      quantity: json['quantity'],
      price: json['unit_price'],
      totalPrice: json['total_price'],
      productName: json['product_name'],
    );
  }
}