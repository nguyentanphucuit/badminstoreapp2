import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/productmodel.dart'; // Import ProductModel
import '../../services/firestore_service.dart';
import '../detail/maindetail.dart'; // Import MainDetail

class OrderDetail extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetail({Key? key, required this.orderId}) : super(key: key);

  @override
  ConsumerState<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends ConsumerState<OrderDetail> {
  OrderModel? orderModel;
  List<OrderItemModel> orderItems = [];
  Map<int, ProductModel> products =
      {}; // To store products by ID for image access
  bool isLoading = true;
  String? errorMessage;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    loadOrderData();
  }

  // Load order data from Firebase
  void loadOrderData() async {
    try {
      print('Loading order data for ID: ${widget.orderId}');

      // Validate order ID
      if (widget.orderId.isEmpty) {
        throw Exception('Order ID không hợp lệ');
      }

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load order from Firebase
      orderModel = await _firestoreService.getOrder(widget.orderId);

      if (orderModel == null) {
        throw Exception('Không tìm thấy đơn hàng với ID ${widget.orderId}');
      }

      print(
        'Order loaded successfully: ${orderModel!.orderCode ?? orderModel!.id}',
      );
      print('Order status: ${orderModel!.orderStatus}');
      print('Payment status: ${orderModel!.paymentStatus}');

      // Get order items from the order
      orderItems = orderModel!.items ?? [];
      print('Found ${orderItems.length} items in order');

      // Load products for order items
      await _loadProductsForOrderItems();

      setState(() {
        isLoading = false;
      });

      print('Order detail page loaded successfully');
    } catch (e) {
      print('Error loading order data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Không thể tải dữ liệu đơn hàng: ${e.toString()}';
      });
    }
  }

  // Load products for order items
  Future<void> _loadProductsForOrderItems() async {
    try {
      print('Loading products for ${orderItems.length} order items');

      // Get all unique product IDs from order items
      Set<String> productIds = {};
      for (var item in orderItems) {
        if (item.productId != null) {
          productIds.add(item.productId!);
        }
      }

      print('Found ${productIds.length} unique product IDs: $productIds');

      // Load products from Firebase
      for (String productId in productIds) {
        try {
          final productData = await _firestoreService.getProduct(productId);
          if (productData != null) {
            ProductModel product = ProductModel.fromJson(productData);
            products[product.id!] = product;
            print('Loaded product: ${product.productName} (ID: ${product.id})');
          } else {
            print('Product not found for ID: $productId');
          }
        } catch (e) {
          print('Error loading product $productId: $e');
          // Continue with other products
        }
      }

      print('Successfully loaded ${products.length} products');
    } catch (e) {
      debugPrint('Error loading products: $e');
      // Continue without products if there's an error
    }
  }

  // Format số tiền
  String formatCurrency(dynamic price) {
    if (price == null) return '0 đ';
    double priceValue =
        price is int ? price.toDouble() : (price is double ? price : 0.0);
    return NumberFormat('#,###').format(priceValue) + ' đ';
  }

  // Format ngày tháng
  String formatDate(dynamic dateInput) {
    if (dateInput == null) return '';
    try {
      DateTime date;
      if (dateInput is DateTime) {
        date = dateInput;
      } else if (dateInput is String) {
        date = DateTime.parse(dateInput);
      } else {
        return '';
      }
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  // Lấy trạng thái thanh toán
  String getPaymentStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'Chưa thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      default:
        return 'Chưa xác định';
    }
  }

  // Lấy trạng thái đơn hàng
  String getOrderStatus(String? status) {
    switch (status) {
      case 'cancelled':
        return 'Đã hủy';
      case 'pending':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Hoàn tất';
      default:
        return 'Không xác định';
    }
  }

  // Lấy màu sắc cho trạng thái
  Color getStatusColor(String? status) {
    switch (status) {
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Tính tổng tiền sản phẩm
  int calculateSubtotal() {
    return orderItems.fold(
      0,
      (sum, item) => sum + (item.totalPrice?.toInt() ?? 0),
    );
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
      const SnackBar(
        content: Text('Chức năng hủy đơn hàng đang được phát triển.'),
      ),
    );

    // After successful cancellation, you might want to refresh the order data
    // loadOrderData();
  }

  @override
  Widget build(BuildContext context) {
    bool showCancelButton =
        (orderModel != null &&
            orderModel!.paymentStatus == 'paid' &&
            orderModel!.orderStatus == 'pending');
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${widget.orderId}'),
        backgroundColor: Color(0xFFFDF1E8),
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Nút refresh
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadOrderData),
        ],
      ),
      body:
          isLoading
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
      bottomNavigationBar:
          showCancelButton
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
                child: SafeArea(
                  // Use SafeArea to avoid conflicts with device's system overlays
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
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
          _buildInfoRow(
            'Mã đơn hàng',
            '#${orderModel?.orderCode ?? orderModel?.id ?? 'N/A'}',
          ),

          const SizedBox(height: 12),

          // Ngày đặt hàng
          _buildInfoRow(
            'Ngày đặt hàng',
            formatDate(orderModel?.orderDate ?? orderModel?.createdAt),
          ),

          const SizedBox(height: 12),

          // Tên người đặt
          _buildInfoRow('Tên người nhận', orderModel?.receiverName ?? 'N/A'),

          const SizedBox(height: 12),

          // Số điện thoại
          _buildInfoRow('Số điện thoại', orderModel?.receiverPhone ?? 'N/A'),

          const SizedBox(height: 12),

          // Email (nếu có)
          if (orderModel?.receiverEmail != null &&
              orderModel!.receiverEmail!.isNotEmpty) ...[
            _buildInfoRow('Email', orderModel!.receiverEmail!),
            const SizedBox(height: 12),
          ],

          // Địa chỉ giao hàng
          _buildInfoRow(
            'Địa chỉ giao hàng',
            orderModel?.shippingAddress ?? 'N/A',
          ),

          const SizedBox(height: 12),

          // Phương thức thanh toán
          _buildInfoRow(
            'Phương thức thanh toán',
            _getPaymentMethodText(orderModel?.paymentMethod),
          ),

          const SizedBox(height: 12),

          // Trạng thái thanh toán
          _buildInfoRow(
            'Trạng thái thanh toán',
            getPaymentStatus(orderModel?.paymentStatus),
          ),

          const SizedBox(height: 16),

          // Đường kẻ phân cách
          const Divider(thickness: 1),

          const SizedBox(height: 8),

          // Tổng tiền sản phẩm
          _buildPriceRow(
            'Tổng tiền sản phẩm',
            formatCurrency(calculateSubtotal()),
          ),

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
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
    if (orderItems.isEmpty) {
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
            Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có sản phẩm nào trong đơn hàng',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                '${orderItems.length} sản phẩm',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Danh sách sản phẩm
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderItems.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              return _buildProductItem(orderItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel orderItem) {
    final product =
        products[int.tryParse(
          orderItem.productId ?? '',
        )]; // Get product data using productId

    return GestureDetector(
      onTap: () {
        // Navigate to product detail using product code if available
        if (orderItem.productCode != null &&
            orderItem.productCode!.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MainDetail.fromCode(productCode: orderItem.productCode!),
            ),
          );
        } else if (orderItem.productId != null) {
          // Fallback to product ID if code is not available
          final productId = int.tryParse(orderItem.productId!);
          if (productId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainDetail.fromId(productId: productId),
              ),
            );
          }
        }
      },
      child: Row(
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
              child: _buildProductImage(orderItem, product),
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
                  orderItem.productName ?? 'Sản phẩm không xác định',
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
                if (orderItem.size != null && orderItem.size!.isNotEmpty)
                  Text(
                    'Size: ${orderItem.size}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                const SizedBox(height: 8),

                // Giá và số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(orderItem.unitPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'x${orderItem.quantity ?? 0}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Tổng tiền sản phẩm
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tổng: ${formatCurrency(orderItem.totalPrice)}',
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
      ),
    );
  }

  // Build product image with fallback handling
  Widget _buildProductImage(OrderItemModel orderItem, ProductModel? product) {
    // Try to use product image first
    if (product != null && product.image != null && product.image!.isNotEmpty) {
      return Image.asset(
        uri_product_img + product.image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }

    // Try to use order item image if available
    if (orderItem.productImage != null && orderItem.productImage!.isNotEmpty) {
      return Image.asset(
        uri_product_img + orderItem.productImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }

    // Fallback to placeholder
    return _buildFallbackImage();
  }

  // Fallback image widget
  Widget _buildFallbackImage() {
    return const Icon(Icons.image_not_supported, size: 30, color: Colors.grey);
  }

  // Get payment method display text
  String _getPaymentMethodText(String? paymentMethod) {
    switch (paymentMethod) {
      case 'momo':
        return 'Ví Momo';
      case 'vnpay':
        return 'VNPAY';
      case 'cash_on_delivery':
      case 'cash':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      default:
        return paymentMethod ?? 'Không xác định';
    }
  }
}
