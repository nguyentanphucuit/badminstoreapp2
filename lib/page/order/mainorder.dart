import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../data/model/productmodel.dart';
import '../../data/model/usermodel.dart';
import '../../data/data/orderdata.dart';
import '../../data/data/orderdetaildata.dart';
import '../../data/data/productdata.dart';
import '../order/orderbody.dart';

class MainOrder extends ConsumerStatefulWidget {
  final UserModel? user;

  const MainOrder({Key? key, this.user}) : super(key: key);

  @override
  ConsumerState<MainOrder> createState() => _MainOrderState();
}

class _MainOrderState extends ConsumerState<MainOrder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> allOrders = [];
  List<OrderModel> userOrders = [];
  List<OrderDetailModel> orderDetails = [];
  List<ProductModel> products = [];
  bool isLoading = true;
  String selectedFilter = 'all';
  String? errorMessage;

  // Data service instances
  final OrderData orderData = OrderData();
  final OrderDetailData orderDetailData = OrderDetailData();
  // final ProductData productData = ProductData(); // Add this when available

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load dữ liệu từ JSON files
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load all data concurrently
      final results = await Future.wait([
        orderData.loadData(),
        orderDetailData.loadData(),
        // productData.loadData(), // Uncomment when ProductData is available
        Future.value(<ProductModel>[]), // Placeholder for products
      ]);

      allOrders = results[0] as List<OrderModel>;
      orderDetails = results[1] as List<OrderDetailModel>;
      products = results[2] as List<ProductModel>;

      // Lọc đơn hàng theo userId nếu có user đăng nhập, nếu không thì hiển thị tất cả
      _filterOrdersByUser();

      // Create products from order details if ProductData is not available
      if (products.isEmpty) {
        products = _createProductsFromOrderDetails();
      }

      // Sort orders by date (newest first)
      userOrders.sort((a, b) {
        DateTime dateA = DateTime.parse(a.orderDate ?? '');
        DateTime dateB = DateTime.parse(b.orderDate ?? '');
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
      });
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Lọc đơn hàng theo userId của user đã đăng nhập, nếu không có user thì hiển thị tất cả
  void _filterOrdersByUser() {
    if (widget.user?.id != null) {
      userOrders =
          allOrders.where((order) => order.userId == widget.user!.id).toList();
    } else {
      // Nếu không có user (chưa đăng nhập), hiển thị tất cả đơn hàng
      userOrders = allOrders;
    }
  }

  // Create product models from order details (temporary solution)
  List<ProductModel> _createProductsFromOrderDetails() {
    Map<int, ProductModel> productMap = {};

    for (var detail in orderDetails) {
      if (detail.productId != null &&
          !productMap.containsKey(detail.productId)) {
        // Extract product name from order detail
        String? productName;
        if (detail is OrderDetailModelWithName) {
          productName = (detail as OrderDetailModelWithName).productName;
        }

        productMap[detail.productId!] = ProductModel(
          id: detail.productId,
          productName: productName ?? 'Sản phẩm ${detail.productId}',
          priceSale: detail.price,
          image: 'default_product.jpg', // Default image
        );
      }
    }

    return productMap.values.toList();
  }

  // Lọc đơn hàng theo trạng thái (chỉ trong đơn hàng của user)
  List<OrderModel> getFilteredOrders() {
    if (selectedFilter == 'all') {
      return userOrders;
    }

    int statusFilter = int.parse(selectedFilter);
    return userOrders
        .where((order) => order.orderStatus == statusFilter)
        .toList();
  }

  // Lấy chi tiết đơn hàng theo orderId (chỉ cho đơn hàng của user)
  List<OrderDetailModel> getOrderDetailsByOrderId(int orderId) {
    return orderDetails.where((detail) => detail.orderId == orderId).toList();
  }

  // Đếm số lượng đơn hàng theo trạng thái (chỉ trong đơn hàng của user)
  int getOrderCountByStatus(String status) {
    if (status == 'all') return userOrders.length;
    int statusValue = int.parse(status);
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
            if (widget.user?.fullname != null)
              Text(
                'Của ${widget.user!.fullname!}',
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
                            List<OrderDetailModel> orderDetailList =
                                getOrderDetailsByOrderId(order.id!);

                            return itemOrderView(
                              order,
                              orderDetailList,
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
          if (selectedFilter == 'all')
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to shopping page (home tab)
                Navigator.pop(context);
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
      ),
    );
  }
}
