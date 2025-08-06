import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id; // Firestore document ID
  String? userId; // Firebase Auth user ID
  String? orderCode; // Custom order code like "ORD-2024-001"
  DateTime? orderDate;
  String? receiverName;
  String? receiverPhone;
  String? receiverEmail;
  String? shippingAddress;
  String? shippingCity;
  String? shippingDistrict;
  String? shippingWard;
  String? shippingNote;
  double? subtotal; // Before shipping and tax
  double? shippingFee;
  double? taxAmount;
  double? totalAmount; // Final total
  String? paymentMethod; // "momo", "vnpay", "cod", etc.
  String? paymentStatus; // "pending", "paid", "failed", "refunded"
  String?
  orderStatus; // "pending", "confirmed", "processing", "shipped", "delivered", "cancelled"
  String? deliveryMethod; // "standard", "express", "pickup"
  DateTime? estimatedDelivery;
  DateTime? actualDelivery;
  List<OrderItemModel>? items; // Order items with product details
  String? notes; // Customer notes
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderModel({
    this.id,
    this.userId,
    this.orderCode,
    this.orderDate,
    this.receiverName,
    this.receiverPhone,
    this.receiverEmail,
    this.shippingAddress,
    this.shippingCity,
    this.shippingDistrict,
    this.shippingWard,
    this.shippingNote,
    this.subtotal,
    this.shippingFee,
    this.taxAmount,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.orderStatus,
    this.deliveryMethod,
    this.estimatedDelivery,
    this.actualDelivery,
    this.items,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // For backward compatibility with JSON data
  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    orderCode = json['order_code'];
    orderDate =
        json['order_date'] != null
            ? DateTime.tryParse(json['order_date'])
            : null;
    receiverName = json['receiver_name'];
    receiverPhone = json['receiver_phone'];
    receiverEmail = json['receiver_email'];
    shippingAddress = json['shipping_address'];
    shippingCity = json['shipping_city'];
    shippingDistrict = json['shipping_district'];
    shippingWard = json['shipping_ward'];
    shippingNote = json['shipping_note'];
    subtotal = json['subtotal']?.toDouble();
    shippingFee = json['shipping_fee']?.toDouble();
    taxAmount = json['tax_amount']?.toDouble();
    totalAmount = json['total_amount']?.toDouble();
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'] ?? json['is_payment']?.toString();
    // Convert integer status to string status
    var statusValue = json['order_status'];
    if (statusValue is int) {
      switch (statusValue) {
        case 0:
          orderStatus = 'cancelled';
          break;
        case 1:
          orderStatus = 'pending';
          break;
        case 2:
          orderStatus = 'shipped';
          break;
        case 3:
          orderStatus = 'delivered';
          break;
        default:
          orderStatus = 'pending';
      }
    } else {
      orderStatus = statusValue?.toString();
    }
    deliveryMethod = json['delivery_method'];
    estimatedDelivery =
        json['estimated_delivery'] != null
            ? DateTime.tryParse(json['estimated_delivery'])
            : null;
    actualDelivery =
        json['actual_delivery'] != null
            ? DateTime.tryParse(json['actual_delivery'])
            : null;
    items =
        json['items'] != null
            ? List<OrderItemModel>.from(
              json['items'].map((x) => OrderItemModel.fromJson(x)),
            )
            : null;
    notes = json['notes'];
    createdAt =
        json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null;
    updatedAt =
        json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null;
  }

  // For Firestore
  OrderModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      print('Processing Firestore data: $data');

      id = doc.id;
      userId = data['userId'];
      orderCode = data['orderCode'];
      orderDate = data['orderDate']?.toDate();
      receiverName = data['receiverName'];
      receiverPhone = data['receiverPhone'];
      receiverEmail = data['receiverEmail'];
      shippingAddress = data['shippingAddress'];
      shippingCity = data['shippingCity'];
      shippingDistrict = data['shippingDistrict'];
      shippingWard = data['shippingWard'];
      shippingNote = data['shippingNote'];
      subtotal = data['subtotal']?.toDouble();
      shippingFee = data['shippingFee']?.toDouble();
      taxAmount = data['taxAmount']?.toDouble();
      totalAmount = data['totalAmount']?.toDouble();
      paymentMethod = data['paymentMethod'];
      paymentStatus = data['paymentStatus'];
      orderStatus = data['orderStatus'];
      deliveryMethod = data['deliveryMethod'];
      estimatedDelivery = data['estimatedDelivery']?.toDate();
      actualDelivery = data['actualDelivery']?.toDate();

      // Process items with error handling
      if (data['items'] != null) {
        try {
          items = List<OrderItemModel>.from(
            data['items'].map((x) => OrderItemModel.fromJson(x)),
          );
          print('Successfully processed ${items?.length ?? 0} items');
        } catch (e) {
          print('Error processing items: $e');
          print('Items data: ${data['items']}');
          items = []; // Set empty list instead of null to avoid errors
        }
      } else {
        items = [];
      }

      // Handle legacy data structure (if totalPrice exists instead of totalAmount)
      if (totalAmount == null && data['totalPrice'] != null) {
        totalAmount = data['totalPrice']?.toDouble();
        print('Using legacy totalPrice field: $totalAmount');
      }

      notes = data['notes'];
      createdAt = data['createdAt']?.toDate();
      updatedAt = data['updatedAt']?.toDate();

      print('Successfully created OrderModel with ID: $id');
    } catch (e) {
      print('Error in OrderModel.fromFirestore: $e');
      print('Document ID: ${doc.id}');
      print('Document data: ${doc.data()}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['orderCode'] = orderCode;
    data['orderDate'] = orderDate?.toIso8601String();
    data['receiverName'] = receiverName;
    data['receiverPhone'] = receiverPhone;
    data['receiverEmail'] = receiverEmail;
    data['shippingAddress'] = shippingAddress;
    data['shippingCity'] = shippingCity;
    data['shippingDistrict'] = shippingDistrict;
    data['shippingWard'] = shippingWard;
    data['shippingNote'] = shippingNote;
    data['subtotal'] = subtotal;
    data['shippingFee'] = shippingFee;
    data['taxAmount'] = taxAmount;
    data['totalAmount'] = totalAmount;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['orderStatus'] = orderStatus;
    data['deliveryMethod'] = deliveryMethod;
    data['estimatedDelivery'] = estimatedDelivery?.toIso8601String();
    data['actualDelivery'] = actualDelivery?.toIso8601String();
    data['items'] = items?.map((x) => x.toJson()).toList();
    data['notes'] = notes;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['orderCode'] = orderCode;
    data['orderDate'] =
        orderDate != null ? Timestamp.fromDate(orderDate!) : null;
    data['receiverName'] = receiverName;
    data['receiverPhone'] = receiverPhone;
    data['receiverEmail'] = receiverEmail;
    data['shippingAddress'] = shippingAddress;
    data['shippingCity'] = shippingCity;
    data['shippingDistrict'] = shippingDistrict;
    data['shippingWard'] = shippingWard;
    data['shippingNote'] = shippingNote;
    data['subtotal'] = subtotal;
    data['shippingFee'] = shippingFee;
    data['taxAmount'] = taxAmount;
    data['totalAmount'] = totalAmount;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['orderStatus'] = orderStatus;
    data['deliveryMethod'] = deliveryMethod;
    data['estimatedDelivery'] =
        estimatedDelivery != null
            ? Timestamp.fromDate(estimatedDelivery!)
            : null;
    data['actualDelivery'] =
        actualDelivery != null ? Timestamp.fromDate(actualDelivery!) : null;
    data['items'] = items?.map((x) => x.toJson()).toList();
    data['notes'] = notes;
    data['createdAt'] =
        createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now();
    data['updatedAt'] = Timestamp.now();
    return data;
  }

  // Generate order code
  static String generateOrderCode() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random =
        (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'ORD-$year$month$day-$random';
  }

  // Get status display text
  String get statusDisplay {
    switch (orderStatus) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đã gửi hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  // Get payment status display text
  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return 'Không xác định';
    }
  }
}

// Order item model for individual products in an order
class OrderItemModel {
  String? productId;
  String? productCode;
  String? productName;
  String? productImage;
  String? size;
  int? quantity;
  double? unitPrice;
  double? totalPrice;

  OrderItemModel({
    this.productId,
    this.productCode,
    this.productName,
    this.productImage,
    this.size,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  OrderItemModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Processing OrderItem JSON: $json');

      productId = json['productId']?.toString();
      productCode = json['productCode']?.toString();
      productName = json['productName']?.toString();
      productImage = json['productImage']?.toString();
      size = json['size']?.toString();
      quantity = json['quantity']?.toInt();
      unitPrice = json['unitPrice']?.toDouble();
      totalPrice = json['totalPrice']?.toDouble();

      print('Successfully created OrderItem with productId: $productId');
    } catch (e) {
      print('Error in OrderItemModel.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['productCode'] = productCode;
    data['productName'] = productName;
    data['productImage'] = productImage;
    data['size'] = size;
    data['quantity'] = quantity;
    data['unitPrice'] = unitPrice;
    data['totalPrice'] = totalPrice;
    return data;
  }
}
