import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../data/model/productmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../order/orderbody.dart';
import '../mainpage.dart';

class MainOrder extends ConsumerStatefulWidget {
  final dynamic user; // Accept Firebase User

  const MainOrder({Key? key, this.user}) : super(key: key);

  @override
  ConsumerState<MainOrder> createState() => _MainOrderState();
}

class _MainOrderState extends ConsumerState<MainOrder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> allOrders = [];
  List<OrderModel> userOrders = [];
  List<ProductModel> products = [];
  bool isLoading = true;
  String selectedFilter = 'all';
  String? errorMessage;

  // Data service instances
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    print('MainOrder initState called');
    _tabController = TabController(length: 5, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load data from Firebase Firestore
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Starting to load orders...');

      // Load orders from Firebase
      allOrders = await _firestoreService.getUserOrders();
      debugPrint('Loaded ${allOrders.length} orders from Firebase');

      // Filter orders by user (Firebase already filters by current user)
      _filterOrdersByUser();

      // Load products for order details
      await _loadProductsForOrders();

      // Sort orders by date (newest first)
      userOrders.sort((a, b) {
        DateTime dateA = a.orderDate ?? DateTime.now();
        DateTime dateB = b.orderDate ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      print('Successfully loaded and processed orders');
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
      });
      debugPrint('Error loading data: $e');
      debugPrint('Error stack trace: ${StackTrace.current}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load products for order details
  Future<void> _loadProductsForOrders() async {
    try {
      // Since orders already contain product information in items,
      // we can create ProductModel objects from the order items
      Set<String> processedProductIds = {};
      List<ProductModel> orderProducts = [];

      for (var order in allOrders) {
        if (order.items != null) {
          for (var item in order.items!) {
            if (item.productId != null &&
                !processedProductIds.contains(item.productId)) {
              processedProductIds.add(item.productId!);

              // Create ProductModel from order item
              orderProducts.add(
                ProductModel(
                  id: int.tryParse(item.productId!),
                  productName: item.productName,
                  priceSale: item.unitPrice?.toInt(),
                  image: item.productImage,
                ),
              );
            }
          }
        }
      }

      products = orderProducts;
    } catch (e) {
      debugPrint('Error loading products: $e');
      // Continue without products if there's an error
    }
  }

  // Filter orders by user (Firebase already filters by current user)
  void _filterOrdersByUser() {
    // Since getUserOrders() already filters by the current Firebase user,
    // we just assign all orders to userOrders
    userOrders = allOrders;
  }

  // Lọc đơn hàng theo trạng thái (chỉ trong đơn hàng của user)
  List<OrderModel> getFilteredOrders() {
    if (selectedFilter == 'all') {
      return userOrders;
    }

    // Convert string filter to order status
    String statusFilter = _convertFilterToStatus(selectedFilter);
    return userOrders
        .where((order) => order.orderStatus == statusFilter)
        .toList();
  }

  // Convert filter string to order status
  String _convertFilterToStatus(String filter) {
    switch (filter) {
      case '0':
        return 'cancelled';
      case '1':
        return 'pending';
      case '2':
        return 'shipped';
      case '3':
        return 'delivered';
      default:
        return 'pending';
    }
  }

  // Get user display name for Firebase User
  String? _getUserDisplayName() {
    if (widget.user is User) {
      return widget.user.displayName ?? widget.user.email;
    }
    return null;
  }

  // Get order details from order items (Firebase structure)
  List<OrderItemModel> getOrderDetailsByOrderId(String orderId) {
    final order = allOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => OrderModel(),
    );
    return order.items ?? [];
  }

  // Đếm số lượng đơn hàng theo trạng thái (chỉ trong đơn hàng của user)
  int getOrderCountByStatus(String status) {
    if (status == 'all') return userOrders.length;
    String statusValue = _convertFilterToStatus(status);
    return userOrders.where((order) => order.orderStatus == statusValue).length;
  }

  @override
  Widget build(BuildContext context) {
    List<OrderModel> filteredOrders = getFilteredOrders();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Đơn hàng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            if (_getUserDisplayName() != null)
              Text(
                'Của ${_getUserDisplayName()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.brown,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.brown),
            onPressed: loadData,
            tooltip: 'Làm mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.brown,
          indicatorColor: Colors.orange,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  selectedFilter = 'all';
                  break;
                case 1:
                  selectedFilter = '1'; // Đang xử lý
                  break;
                case 2:
                  selectedFilter = '2'; // Đang giao hàng
                  break;
                case 3:
                  selectedFilter = '3'; // Hoàn tất
                  break;
                case 4:
                  selectedFilter = '0'; // Đã hủy
                  break;
              }
            });
          },
          tabs: [
            Tab(text: 'Tất cả (${getOrderCountByStatus('all')})'),
            Tab(text: 'Đang xử lý (${getOrderCountByStatus('1')})'),
            Tab(text: 'Đang giao (${getOrderCountByStatus('2')})'),
            Tab(text: 'Hoàn tất (${getOrderCountByStatus('3')})'),
            Tab(text: 'Đã hủy (${getOrderCountByStatus('0')})'),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Đang tải đơn hàng...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                onRefresh: loadData,
                child:
                    filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            OrderModel order = filteredOrders[index];
                            List<OrderItemModel> orderItemList =
                                getOrderDetailsByOrderId(order.id!);

                            return itemOrderView(
                              order,
                              orderItemList,
                              products,
                              ref,
                            );
                          },
                        ),
              ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = '';
    IconData icon = Icons.shopping_bag_outlined;

    switch (selectedFilter) {
      case 'all':
        message = 'Không có đơn hàng nào';
        break;
      case '0':
        message = 'Không có đơn hàng bị hủy';
        icon = Icons.cancel_outlined;
        break;
      case '1':
        message = 'Không có đơn hàng đang xử lý';
        icon = Icons.hourglass_empty_outlined;
        break;
      case '2':
        message = 'Không có đơn hàng đang giao';
        icon = Icons.local_shipping_outlined;
        break;
      case '3':
        message = 'Không có đơn hàng đã hoàn tất';
        icon = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để làm mới',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          if (selectedFilter == 'all') ...[
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to home page by going back to main page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Mua sắm ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Test Firebase connection
  Future<void> _testFirebaseConnection() async {
    try {
      print('Testing Firebase connection...');

      // Test getting user orders
      final orders = await _firestoreService.getUserOrders();
      print('Test: Found ${orders.length} orders');

      // Show result in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase test: Found ${orders.length} orders'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Firebase test error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase test error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
