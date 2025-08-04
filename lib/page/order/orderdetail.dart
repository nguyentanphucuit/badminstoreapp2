import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Import for rootBundle
import 'dart:convert'; // Import for jsonDecode
import '../../conf/const.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../data/model/productmodel.dart'; // Import ProductModel

class OrderDetail extends ConsumerStatefulWidget {
  final int orderId;
  
  const OrderDetail({Key? key, required this.orderId}) : super(key: key);

  @override
  ConsumerState<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends ConsumerState<OrderDetail> {
  OrderModel? orderModel;
  List<OrderDetailModelWithName> orderDetails = [];
  Map<int, ProductModel> products = {}; // To store products by ID for image access
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadOrderData();
  }

  // Load dữ liệu order và order details từ JSON
  void loadOrderData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Mô phỏng API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      //Load và parse dữ liệu từ JSON
      await _loadDataFromJson();
      
      setState(() {
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Không thể tải dữ liệu đơn hàng: ${e.toString()}';
      });
    }
  }
  
  // Load dữ liệu từ JSON files
  Future<void> _loadDataFromJson() async {
    try {
      // Load orders from orderlist.json
      final String orderListString = await rootBundle.loadString("assets/files/orderlist.json");
      final Map<String, dynamic> orderListJson = jsonDecode(orderListString);

      // Load order details from orderdetaillist.json
      final String orderDetailListString = await rootBundle.loadString("assets/files/orderdetaillist.json");
      final Map<String, dynamic> orderDetailListJson = jsonDecode(orderDetailListString);

      // Load products from productlist.json
      final String productListString = await rootBundle.loadString("assets/files/productlist.json");
      final Map<String, dynamic> productListJson = jsonDecode(productListString);

      // Populate products map
      for (var item in (productListJson['data'] as List)) {
        ProductModel product = ProductModel.fromJson(item);
        products[product.id!] = product;
      }

      // Tìm order theo ID
      final orderData = orderListJson['data']?.firstWhere(
        (order) => order['id'] == widget.orderId
      );

      if (orderData == null) {
        throw Exception('Không tìm thấy đơn hàng với ID ${widget.orderId}');
      }

      // Parse order model
      orderModel = OrderModel.fromJson(orderData);

      // Tìm tất cả order details theo order_id
      final List<dynamic> orderDetailsData = orderDetailListJson['data']?.where(
        (detail) => detail['order_id'] == widget.orderId,
      ).toList() ?? [];

      // Parse order details
      orderDetails = orderDetailsData
          .map((detail) => OrderDetailModelWithName.fromJson(detail))
          .toList();

    } catch (e) {
      throw Exception('Lỗi khi xử lý dữ liệu: ${e.toString()}');
    }
  } 

  // Format số tiền
  String formatCurrency(int? price) {
    if (price == null) return '0 đ';
    return NumberFormat('#,###').format(price) + ' đ';
  }

  // Format ngày tháng
  String formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Lấy trạng thái thanh toán
  String getPaymentStatus(int? isPayment) {
    switch (isPayment) {
      case 0:
        return 'Chưa thanh toán';
      case 1:
        return 'Thanh toán tiền mặt khi nhận hàng';
      case 2:
        return 'Đã thanh toán';
      default:
        return 'Chưa xác định';
    }
  }

  // Lấy trạng thái đơn hàng
  String getOrderStatus(int? status) {
    switch (status) {
      case 0:
        return 'Đã hủy';
      case 1:
        return 'Đang xử lý';
      case 2:
        return 'Đang giao hàng';
      case 3:
        return 'Hoàn tất';
      default:
        return 'Không xác định';
    }
  }

  // Lấy màu sắc cho trạng thái
  Color getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Tính tổng tiền sản phẩm
  int calculateSubtotal() {
    return orderDetails.fold(0, (sum, item) => sum + (item.totalPrice ?? 0));
  }

  // Phí ship cố định
  int getShippingFee() {
    return 20000; // 20,000 VND
  }

  // Hàm xử lý khi nhấn nút "Hủy đơn hàng"
  void _cancelOrder() {
    // TODO: Implement actual order cancellation logic
    // This could involve:
    // 1. Making an API call to update the order status on the backend.
    // 2. Showing a confirmation dialog to the user.
    // 3. Updating the local orderModel status and refreshing the UI.

    // For demonstration, let's just show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng hủy đơn hàng đang được phát triển.')),
    );

    // After successful cancellation, you might want to refresh the order data
    // loadOrderData();
  }

  @override
  Widget build(BuildContext context) {
    bool showCancelButton = (orderModel != null && 
                             orderModel!.isPayment == 1 && 
                             orderModel!.orderStatus == 1);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${widget.orderId}'),
        backgroundColor: Color(0xFFFDF1E8),
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadOrderData,
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
          ? _buildErrorWidget()
          : orderModel == null
            ? _buildNoDataWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần 1: Chi tiết đơn hàng
                    _buildOrderInfoSection(),
                    
                    const SizedBox(height: 16),
                    
                    // Phần 2: Danh sách sản phẩm
                    _buildProductListSection(),
                  ],
                ),
              ),
      bottomNavigationBar: showCancelButton
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea( // Use SafeArea to avoid conflicts with device's system overlays
                child: ElevatedButton(
                  onPressed: _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Màu đỏ cho nút hủy
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Hủy đơn hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,   
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadOrderData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy thông tin đơn hàng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết đơn hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mã đơn hàng
          _buildInfoRow('Mã đơn hàng', '#${orderModel?.id ?? 'N/A'}'),
          
          const SizedBox(height: 12),
          
          // Ngày đặt hàng
          _buildInfoRow('Ngày đặt hàng', formatDate(orderModel?.orderDate)),
          
          const SizedBox(height: 12),
          
          // Tên người đặt
          _buildInfoRow('Tên người nhận', orderModel?.receiverName ?? 'N/A'),
          
          const SizedBox(height: 12),
          
          // Số điện thoại
          _buildInfoRow('Số điện thoại', orderModel?.receiverPhone ?? 'N/A'),
          
          const SizedBox(height: 12),
          
          // Địa chỉ giao hàng
          _buildInfoRow('Địa chỉ giao hàng', orderModel?.shippingAddress ?? 'N/A'),
          
          const SizedBox(height: 12),
          
          // Trạng thái thanh toán
          _buildInfoRow('Trạng thái thanh toán', getPaymentStatus(orderModel?.isPayment)),
          
          const SizedBox(height: 16),
          
          // Đường kẻ phân cách
          const Divider(thickness: 1),
          
          const SizedBox(height: 8),
          
          // Tổng tiền sản phẩm
          _buildPriceRow('Tổng tiền sản phẩm', formatCurrency(calculateSubtotal())),
          
          const SizedBox(height: 8),
          
          // Phí shipping
          _buildPriceRow('Phí vận chuyển', formatCurrency(getShippingFee())),
          
          const SizedBox(height: 8),
          
          // Đường kẻ phân cách
          const Divider(thickness: 1),
          
          const SizedBox(height: 8),
          
          // Tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                formatCurrency(orderModel?.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Trạng thái đơn hàng
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: getStatusColor(orderModel?.orderStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: getStatusColor(orderModel?.orderStatus),
                  width: 1,
                ),
              ),
              child: Text(
                getOrderStatus(orderModel?.orderStatus),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: getStatusColor(orderModel?.orderStatus),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductListSection() {
    if (orderDetails.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không có sản phẩm nào trong đơn hàng',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm đã đặt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${orderDetails.length} sản phẩm',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Danh sách sản phẩm
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderDetails.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              return _buildProductItem(orderDetails[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderDetailModelWithName orderDetail){
    final product = products[orderDetail.productId]; // Get product data using productId
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hình ảnh sản phẩm
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (product != null && product.image != null && product.image!.isNotEmpty)
                ? Image.asset(
                    uri_product_img + product.image!, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                  )
                : const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Thông tin sản phẩm
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên sản phẩm
              Text(
                orderDetail.productName ?? 'Sản phẩm không xác định',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Size (nếu có)
              if (orderDetail.Size != null && orderDetail.Size!.isNotEmpty)
                Text(
                  'Size: ${orderDetail.Size}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Giá và số lượng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatCurrency(orderDetail.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'x${orderDetail.quantity ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Tổng tiền sản phẩm
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tổng: ${formatCurrency(orderDetail.totalPrice)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}