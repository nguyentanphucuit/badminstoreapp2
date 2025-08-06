import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/ordermodel.dart';
import '../data/model/cartitemmodel.dart';
import 'firestore_service.dart';

class OrderService {
  final FirestoreService _firestoreService;

  OrderService(this._firestoreService);

  /// Creates a new order
  Future<String> createOrder(OrderModel order) async {
    return await _firestoreService.createOrder(order);
  }

  /// Creates an order from cart items
  Future<String> createOrderFromCart({
    required List<CartItemModel> cartItems,
    required String receiverName,
    required String receiverPhone,
    String? receiverEmail,
    required String shippingAddress,
    String? shippingCity,
    String? shippingDistrict,
    String? shippingWard,
    String? shippingNote,
    required String paymentMethod,
    String? deliveryMethod,
    String? notes,
  }) async {
    return await _firestoreService.createOrderFromCart(
      cartItems: cartItems,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      receiverEmail: receiverEmail,
      shippingAddress: shippingAddress,
      shippingCity: shippingCity,
      shippingDistrict: shippingDistrict,
      shippingWard: shippingWard,
      shippingNote: shippingNote,
      paymentMethod: paymentMethod,
      deliveryMethod: deliveryMethod,
      notes: notes,
    );
  }

  /// Gets all orders for the current user
  Future<List<OrderModel>> getUserOrders() async {
    return await _firestoreService.getUserOrders();
  }

  /// Gets a specific order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    return await _firestoreService.getOrder(orderId);
  }

  /// Updates order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    return await _firestoreService.updateOrderStatus(orderId, newStatus);
  }

  /// Updates payment status
  Future<void> updatePaymentStatus(
    String orderId,
    String newPaymentStatus,
  ) async {
    return await _firestoreService.updatePaymentStatus(
      orderId,
      newPaymentStatus,
    );
  }

  /// Cancels an order
  Future<void> cancelOrder(String orderId) async {
    return await _firestoreService.cancelOrder(orderId);
  }

  /// Gets orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    return await _firestoreService.getOrdersByStatus(status);
  }

  /// Gets orders within a date range
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _firestoreService.getOrdersByDateRange(startDate, endDate);
  }

  /// Gets order statistics for the current user
  Future<Map<String, dynamic>> getOrderStatistics() async {
    return await _firestoreService.getOrderStatistics();
  }

  /// Gets pending orders
  Future<List<OrderModel>> getPendingOrders() async {
    return await getOrdersByStatus('pending');
  }

  /// Gets confirmed orders
  Future<List<OrderModel>> getConfirmedOrders() async {
    return await getOrdersByStatus('confirmed');
  }

  /// Gets processing orders
  Future<List<OrderModel>> getProcessingOrders() async {
    return await getOrdersByStatus('processing');
  }

  /// Gets shipped orders
  Future<List<OrderModel>> getShippedOrders() async {
    return await getOrdersByStatus('shipped');
  }

  /// Gets delivered orders
  Future<List<OrderModel>> getDeliveredOrders() async {
    return await getOrdersByStatus('delivered');
  }

  /// Gets cancelled orders
  Future<List<OrderModel>> getCancelledOrders() async {
    return await getOrdersByStatus('cancelled');
  }

  /// Gets recent orders (last 30 days)
  Future<List<OrderModel>> getRecentOrders() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));
    return await getOrdersByDateRange(thirtyDaysAgo, now);
  }

  /// Confirms an order (changes status from pending to confirmed)
  Future<void> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'confirmed');
  }

  /// Marks an order as processing
  Future<void> processOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'processing');
  }

  /// Marks an order as shipped
  Future<void> shipOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'shipped');
  }

  /// Marks an order as delivered
  Future<void> deliverOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'delivered');
  }

  /// Marks payment as paid
  Future<void> markPaymentAsPaid(String orderId) async {
    return await updatePaymentStatus(orderId, 'paid');
  }

  /// Marks payment as failed
  Future<void> markPaymentAsFailed(String orderId) async {
    return await updatePaymentStatus(orderId, 'failed');
  }

  /// Marks payment as refunded
  Future<void> markPaymentAsRefunded(String orderId) async {
    return await updatePaymentStatus(orderId, 'refunded');
  }
}

// Provider for Order Service
final orderServiceProvider = Provider<OrderService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OrderService(firestoreService);
});

// Provider for user orders from Firestore
final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getUserOrders();
});

// Provider for order statistics
final orderStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrderStatistics();
});

// Provider for pending orders
final pendingOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getPendingOrders();
});

// Provider for recent orders
final recentOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getRecentOrders();
});
