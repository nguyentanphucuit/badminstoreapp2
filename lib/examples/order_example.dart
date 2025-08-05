import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/cartitemmodel.dart';
import '../data/model/productmodel.dart';
import '../services/order_service.dart';

/// Example widget demonstrating how to use the OrderService
class OrderExample extends ConsumerStatefulWidget {
  const OrderExample({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderExample> createState() => _OrderExampleState();
}

class _OrderExampleState extends ConsumerState<OrderExample> {
  final _formKey = GlobalKey<FormState>();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _orderNotesController = TextEditingController();

  String _selectedPaymentMethod = 'cash_on_delivery';
  bool _isLoading = false;

  // Sample cart items for demonstration
  List<CartItemModel> _sampleCartItems = [];

  @override
  void initState() {
    super.initState();
    _createSampleCartItems();
  }

  void _createSampleCartItems() {
    // Create sample products
    final product1 = ProductModel(
      id: 1,
      productName: 'Áo cầu lông Yonex',
      priceSale: 500000,
      image: 'ao-cau-long-yonex.jpg',
    );

    final product2 = ProductModel(
      id: 2,
      productName: 'Vợt cầu lông Victor',
      priceSale: 1200000,
      image: 'vot-cau-long-victor.jpg',
    );

    // Create cart items
    _sampleCartItems = [
      CartItemModel(product: product1, quantity: 2, size: 'L'),
      CartItemModel(product: product2, quantity: 1, size: '4U'),
    ];
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _shippingAddressController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  /// Example function to save an order
  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderService = ref.read(orderServiceProvider);

      // Calculate total price
      final totalPrice = orderService.calculateTotalPrice(_sampleCartItems);

      // Create shipping info
      final shippingInfo = orderService.createShippingInfo(
        receiverName: _receiverNameController.text,
        receiverPhone: _receiverPhoneController.text,
        shippingAddress: _shippingAddressController.text,
      );

      // Save order to Firebase
      final orderId = await orderService.saveOrder(
        cartItems: _sampleCartItems,
        totalPrice: totalPrice,
        shippingInfo: shippingInfo,
        paymentMethod: _selectedPaymentMethod,
        orderNotes: _orderNotesController.text,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order saved successfully! Order ID: $orderId'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _orderNotesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Example function to get user orders
  Future<void> _getUserOrders() async {
    try {
      final orderService = ref.read(orderServiceProvider);
      // You would typically get the user ID from Firebase Auth
      final userId = 'example_user_id';
      final orders = await orderService.getUserOrders(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${orders.length} orders'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderService = ref.watch(orderServiceProvider);
    final totalPrice = orderService.calculateTotalPrice(_sampleCartItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Service Example'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cart Items Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cart Items:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._sampleCartItems.map(
                        (item) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/products/${item.product.image}',
                            ),
                          ),
                          title: Text(item.product.productName ?? ''),
                          subtitle: Text('Size: ${item.size ?? 'N/A'}'),
                          trailing: Text(
                            '${item.quantity} x ${item.product.priceSale?.toStringAsFixed(0)}đ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Divider(),
                      Text(
                        'Total: ${totalPrice.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Shipping Information Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shipping Information:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _receiverNameController,
                        decoration: const InputDecoration(
                          labelText: 'Receiver Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter receiver name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _receiverPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Receiver Phone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter receiver phone';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _shippingAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Shipping Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter shipping address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'cash_on_delivery',
                            child: Text('Cash on Delivery'),
                          ),
                          DropdownMenuItem(
                            value: 'bank_transfer',
                            child: Text('Bank Transfer'),
                          ),
                          DropdownMenuItem(value: 'momo', child: Text('MoMo')),
                          DropdownMenuItem(
                            value: 'vnpay',
                            child: Text('VNPay'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Order Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Notes (Optional):',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _orderNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveOrder,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getUserOrders,
                      icon: const Icon(Icons.list),
                      label: const Text('Get Orders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example function that can be called from anywhere in the app
class OrderServiceExample {
  static Future<String> saveOrderExample({
    required List<CartItemModel> cartItems,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    String? paymentMethod,
    String? orderNotes,
  }) async {
    // This would typically be called with a Provider
    // For demonstration, we'll show the structure

    // 1. Create shipping info
    final shippingInfo = {
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'shippingAddress': shippingAddress,
    };

    // 2. Calculate total price
    final totalPrice = cartItems.fold(
      0.0,
      (total, item) => total + item.totalPrice,
    );

    // 3. Save order (this would use the actual service)
    // final orderService = ref.read(orderServiceProvider);
    // final orderId = await orderService.saveOrder(
    //   cartItems: cartItems,
    //   totalPrice: totalPrice,
    //   shippingInfo: shippingInfo,
    //   paymentMethod: paymentMethod,
    //   orderNotes: orderNotes,
    // );

    // For demonstration, return a mock order ID
    return 'mock_order_id_${DateTime.now().millisecondsSinceEpoch}';
  }
}
