import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
//import '../../conf/const.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../data/model/productmodel.dart';
import '../../page/order/orderdetail.dart';
// Import your OrderDetail page when available
// import '../../page/detail/orderdetail.dart';

Widget itemOrderView(
  OrderModel orderModel, 
  List<OrderDetailModel> orderDetails,
  List<ProductModel> products,
  WidgetRef ref
) {
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

  // Lấy icon cho trạng thái
  IconData getStatusIcon(int? status) {
    switch (status) {
      case 0:
        return Icons.cancel;
      case 1:
        return Icons.hourglass_empty;
      case 2:
        return Icons.local_shipping;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  // Lấy danh sách sản phẩm của đơn hàng
  List<ProductModel> getOrderProducts() {
    List<ProductModel> orderProducts = [];
    for (var detail in orderDetails) {
      if (detail.orderId == orderModel.id) {
        // First try to find product in products list
        var product = products.firstWhere(
          (p) => p.id == detail.productId,
          orElse: () => ProductModel(),
        );
        
        // If product not found in products list, create from order detail
        if (product.id == null) {
          String? productName;
          if (detail.runtimeType.toString().contains('WithProductName')) {
            productName = (detail as dynamic).productName;
          }
          
          product = ProductModel(
            id: detail.productId,
            productName: productName ?? 'Sản phẩm ${detail.productId}',
            priceSale: detail.price,
            image: 'default_product.jpg',
          );
        }
        
        if (product.id != null) {
          orderProducts.add(product);
        }
      }
    }
    return orderProducts;
  }

  // Đếm tổng số sản phẩm (bao gồm cả trùng lặp)
  int getTotalProductCount() {
    int count = 0;
    for (var detail in orderDetails) {
      if (detail.orderId == orderModel.id) {
        count += detail.quantity ?? 0;
      }
    }
    return count;
  }

  List<ProductModel> orderProducts = getOrderProducts();
  int totalProducts = getTotalProductCount();

  return GestureDetector(
    onTap: () {
      // Navigate to OrderDetail page when order is tapped
      // Uncomment when OrderDetail page is available
      /*
      Navigator.push(
        ref.context,
        MaterialPageRoute(
          builder: (context) => OrderDetail(orderId: orderModel.id!),
        ),
      );
      */
      Navigator.push(
        ref.context,
        MaterialPageRoute(
          builder: (context) => OrderDetail(orderId: orderModel.id!),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với mã đơn hàng và icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đơn hàng #${orderModel.id ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Ngày đặt hàng
            Text(
              formatDate(orderModel.orderDate),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            /*
            // Hình ảnh sản phẩm (tối đa 6 hình)
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  // Hiển thị tối đa 6 hình sản phẩm
                  ...orderProducts.take(6).map((product) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          uri_product_img + product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.image, size: 25, color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Hiển thị số sản phẩm còn lại nếu > 6
                  if (orderProducts.length > 6)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          '+${orderProducts.length - 6}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ), */
            
            const SizedBox(height: 16),
            
            // Thông tin đơn hàng (Trạng thái, Sản phẩm, Tổng tiền)
            Row(
              children: [
                // Trạng thái
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            getStatusIcon(orderModel.orderStatus),
                            size: 16,
                            color: getStatusColor(orderModel.orderStatus),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              getOrderStatus(orderModel.orderStatus),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: getStatusColor(orderModel.orderStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sản phẩm',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalProducts Sản phẩm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tổng tiền
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(orderModel.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
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