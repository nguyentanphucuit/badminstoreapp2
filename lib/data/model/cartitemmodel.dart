import 'productmodel.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String? size;

  CartItemModel({
    required this.product,
    required this.quantity,
    this.size,
  });

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? size,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }

  // Tính tổng giá cho item này
  int get totalPrice => (product.priceSale ?? 0) * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      size: json['size'],
    );
  }
}