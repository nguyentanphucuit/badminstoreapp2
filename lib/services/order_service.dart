import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/cartitemmodel.dart';
import 'firestore_service.dart';

class OrderService {
  final FirestoreService _firestoreService;

  OrderService(this._firestoreService);

  /// Saves an order to Firebase Firestore
  ///
  /// This function creates a complete order record with:
  /// - User ID (from Firebase Auth or provided)
  /// - Total price
  /// - List of products with quantities and prices
  /// - Timestamp (server timestamp)
  /// - Shipping information
  /// - Payment method
  /// - Order status
  ///
  /// [cartItems] - List of cart items to be ordered
  /// [totalPrice] - Total price of the order
  /// [shippingInfo] - Map containing receiver name, phone, and address
  /// [paymentMethod] - Payment method (default: cash_on_delivery)
  /// [userId] - Optional user ID (uses current user if not provided)
  /// [orderNotes] - Optional notes for the order
  ///
  /// Returns the order ID as a String
  Future<String> saveOrder({
    required List<CartItemModel> cartItems,
    required double totalPrice,
    required Map<String, String> shippingInfo,
    String? paymentMethod,
    String? userId,
    String? orderNotes,
  }) async {
    try {
      // Validate inputs
      if (cartItems.isEmpty) {
        throw 'Cart items cannot be empty';
      }

      if (totalPrice <= 0) {
        throw 'Total price must be greater than 0';
      }

      if (shippingInfo['receiverName']?.isEmpty ?? true) {
        throw 'Receiver name is required';
      }

      if (shippingInfo['receiverPhone']?.isEmpty ?? true) {
        throw 'Receiver phone is required';
      }

      if (shippingInfo['shippingAddress']?.isEmpty ?? true) {
        throw 'Shipping address is required';
      }

      // Save order using FirestoreService
      final orderId = await _firestoreService.saveOrder(
        cartItems: cartItems,
        totalPrice: totalPrice,
        shippingInfo: shippingInfo,
        paymentMethod: paymentMethod,
        userId: userId,
        orderNotes: orderNotes,
      );

      return orderId;
    } catch (e) {
      throw 'Failed to save order: $e';
    }
  }

  /// Gets all orders for a specific user
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      return await _firestoreService.getUserOrders(userId);
    } catch (e) {
      throw 'Failed to get user orders: $e';
    }
  }

  /// Gets a specific order by ID
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      return await _firestoreService.getOrder(orderId);
    } catch (e) {
      throw 'Failed to get order: $e';
    }
  }

  /// Updates the status of an order
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  /// Updates the payment status of an order
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _firestoreService.updatePaymentStatus(orderId, paymentStatus);
    } catch (e) {
      throw 'Failed to update payment status: $e';
    }
  }

  /// Calculates total price from cart items
  double calculateTotalPrice(List<CartItemModel> cartItems) {
    return cartItems.fold(0.0, (total, item) => total + item.totalPrice);
  }

  /// Validates cart items before saving order
  bool validateCartItems(List<CartItemModel> cartItems) {
    if (cartItems.isEmpty) return false;

    for (final item in cartItems) {
      if (item.quantity <= 0) return false;
      if (item.product.priceSale == null || item.product.priceSale! <= 0)
        return false;
    }

    return true;
  }

  /// Creates shipping info map from individual fields
  Map<String, String> createShippingInfo({
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
  }) {
    return {
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'shippingAddress': shippingAddress,
    };
  }
}

// Provider for Order Service
final orderServiceProvider = Provider<OrderService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OrderService(firestoreService);
});
