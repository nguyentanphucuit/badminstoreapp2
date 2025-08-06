import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import '../data/model/ordermodel.dart';
import '../data/model/cartitemmodel.dart';
import '../data/model/productmodel.dart';

class OrderExample extends ConsumerStatefulWidget {
  const OrderExample({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderExample> createState() => _OrderExampleState();
}

class _OrderExampleState extends ConsumerState<OrderExample> {
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Management Example'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Management System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Create Order Section
            _buildSection('Create Order', [
              ElevatedButton(
                onPressed: _createSampleOrder,
                child: Text('Create Sample Order'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _createOrderFromCart,
                child: Text('Create Order from Cart'),
              ),
            ]),

            // View Orders Section
            _buildSection('View Orders', [
              ElevatedButton(
                onPressed: _getUserOrders,
                child: Text('Get All Orders'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getOrderStatistics,
                child: Text('Get Order Statistics'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getRecentOrders,
                child: Text('Get Recent Orders'),
              ),
            ]),

            // Order Management Section
            _buildSection('Order Management', [
              ElevatedButton(
                onPressed: _getPendingOrders,
                child: Text('Get Pending Orders'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getDeliveredOrders,
                child: Text('Get Delivered Orders'),
              ),
            ]),

            // Results Section
            if (_result.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _result,
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],

            // Orders List
            SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                final ordersAsync = ref.watch(userOrdersProvider);

                return ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Text('No orders found');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Orders (${orders.length}):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ...orders
                            .map((order) => _buildOrderCard(order))
                            .toList(),
                      ],
                    );
                  },
                  loading: () => CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...children,
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order: ${order.orderCode ?? "N/A"}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus ?? ''),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt ?? DateTime.now())}',
            ),
            Text('Receiver: ${order.receiverName ?? "N/A"}'),
            Text('Phone: ${order.receiverPhone ?? "N/A"}'),
            Text(
              'Total: ${NumberFormat('#,###').format(order.totalAmount ?? 0)} đ',
            ),
            Text('Payment: ${order.paymentStatusDisplay}'),
            if (order.items != null && order.items!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Items: ${order.items!.length} products'),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Example methods
  Future<void> _createSampleOrder() async {
    try {
      final orderService = ref.read(orderServiceProvider);

      // Create sample order items
      final items = [
        OrderItemModel(
          productId: '1',
          productCode: 'VNB000001',
          productName: 'Vợt Cầu Lông Yonex Astrox 77 Pro',
          productImage:
              'vot-cau-long-yonex-astrox-77-pro-xanh-china-limited-noi-dia-trung_1726539659.webp',
          size: '4U',
          quantity: 1,
          unitPrice: 13500000.0,
          totalPrice: 13500000.0,
        ),
        OrderItemModel(
          productId: '2',
          productCode: 'VNB000002',
          productName: 'Giày cầu lông Yonex SHB 65Z4 Slim 2025',
          productImage:
              'giay-cau-long-yonex-shb-65z4-slim-trang-2025-chinh-hang_1736970583.webp',
          size: '42',
          quantity: 1,
          unitPrice: 2849000.0,
          totalPrice: 2849000.0,
        ),
      ];

      final order = OrderModel(
        orderCode: OrderModel.generateOrderCode(),
        receiverName: 'Nguyễn Văn A',
        receiverPhone: '0123456789',
        receiverEmail: 'nguyenvana@example.com',
        shippingAddress: '123 Đường ABC, Quận 1',
        shippingCity: 'TP.HCM',
        shippingDistrict: 'Quận 1',
        shippingWard: 'Phường Bến Nghé',
        subtotal: 16349000.0,
        shippingFee: 30000.0,
        taxAmount: 1634900.0,
        totalAmount: 18023890.0,
        paymentMethod: 'momo',
        paymentStatus: 'pending',
        orderStatus: 'pending',
        deliveryMethod: 'standard',
        items: items,
        notes: 'Giao hàng vào giờ hành chính',
      );

      final orderId = await orderService.createOrder(order);
      setState(() {
        _result =
            'Order created successfully!\nOrder ID: $orderId\nOrder Code: ${order.orderCode}';
      });

      // Refresh the orders list
      ref.invalidate(userOrdersProvider);
    } catch (e) {
      setState(() {
        _result = 'Error creating order: $e';
      });
    }
  }

  Future<void> _createOrderFromCart() async {
    try {
      final orderService = ref.read(orderServiceProvider);

      // Create sample cart items
      final cartItems = [
        CartItemModel(
          product: ProductModel(
            id: 1,
            productName: 'Vợt Cầu Lông Yonex Astrox 77 Pro',
            code: 'VNB000001',
            image:
                'vot-cau-long-yonex-astrox-77-pro-xanh-china-limited-noi-dia-trung_1726539659.webp',
            priceSale: 13500000,
          ),
          quantity: 1,
          size: '4U',
        ),
        CartItemModel(
          product: ProductModel(
            id: 2,
            productName: 'Giày cầu lông Yonex SHB 65Z4 Slim 2025',
            code: 'VNB000002',
            image:
                'giay-cau-long-yonex-shb-65z4-slim-trang-2025-chinh-hang_1736970583.webp',
            priceSale: 2849000,
          ),
          quantity: 1,
          size: '42',
        ),
      ];

      final orderId = await orderService.createOrderFromCart(
        cartItems: cartItems,
        receiverName: 'Nguyễn Văn B',
        receiverPhone: '0987654321',
        receiverEmail: 'nguyenvanb@example.com',
        shippingAddress: '456 Đường XYZ, Quận 2',
        shippingCity: 'TP.HCM',
        shippingDistrict: 'Quận 2',
        shippingWard: 'Phường Thủ Thiêm',
        paymentMethod: 'vnpay',
        deliveryMethod: 'express',
        notes: 'Giao hàng nhanh',
      );

      setState(() {
        _result = 'Order created from cart successfully!\nOrder ID: $orderId';
      });

      // Refresh the orders list
      ref.invalidate(userOrdersProvider);
    } catch (e) {
      setState(() {
        _result = 'Error creating order from cart: $e';
      });
    }
  }

  Future<void> _getUserOrders() async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final orders = await orderService.getUserOrders();

      setState(() {
        _result =
            'Found ${orders.length} orders:\n\n' +
            orders
                .map(
                  (order) =>
                      '${order.orderCode}: ${order.receiverName} - ${order.statusDisplay} - ${NumberFormat('#,###').format(order.totalAmount ?? 0)} đ',
                )
                .join('\n');
      });
    } catch (e) {
      setState(() {
        _result = 'Error getting orders: $e';
      });
    }
  }

  Future<void> _getOrderStatistics() async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final stats = await orderService.getOrderStatistics();

      setState(() {
        _result =
            'Order Statistics:\n\n' +
            'Total Orders: ${stats['totalOrders']}\n' +
            'Pending Orders: ${stats['pendingOrders']}\n' +
            'Completed Orders: ${stats['completedOrders']}\n' +
            'Cancelled Orders: ${stats['cancelledOrders']}\n' +
            'Total Spent: ${NumberFormat('#,###').format(stats['totalSpent'])} đ';
      });
    } catch (e) {
      setState(() {
        _result = 'Error getting statistics: $e';
      });
    }
  }

  Future<void> _getRecentOrders() async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final orders = await orderService.getRecentOrders();

      setState(() {
        _result =
            'Recent Orders (last 30 days):\n\n' +
            orders
                .map(
                  (order) =>
                      '${order.orderCode}: ${order.receiverName} - ${order.statusDisplay}',
                )
                .join('\n');
      });
    } catch (e) {
      setState(() {
        _result = 'Error getting recent orders: $e';
      });
    }
  }

  Future<void> _getPendingOrders() async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final orders = await orderService.getPendingOrders();

      setState(() {
        _result =
            'Pending Orders:\n\n' +
            orders
                .map(
                  (order) =>
                      '${order.orderCode}: ${order.receiverName} - ${order.paymentStatusDisplay}',
                )
                .join('\n');
      });
    } catch (e) {
      setState(() {
        _result = 'Error getting pending orders: $e';
      });
    }
  }

  Future<void> _getDeliveredOrders() async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final orders = await orderService.getDeliveredOrders();

      setState(() {
        _result =
            'Delivered Orders:\n\n' +
            orders
                .map(
                  (order) =>
                      '${order.orderCode}: ${order.receiverName} - ${order.paymentStatusDisplay}',
                )
                .join('\n');
      });
    } catch (e) {
      setState(() {
        _result = 'Error getting delivered orders: $e';
      });
    }
  }
}
