import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart';
import '../../data/model/productmodel.dart';
import '../../page/detail/maindetail.dart'; // Import your MainDetail page

Widget itemGridView(ProductModel productModel, WidgetRef ref) {
  // Format số tiền
  String formatCurrency(int? price) {
    if (price == null) return '0 đ';
    return NumberFormat('#,###').format(price) + ' đ';
  }

  return GestureDetector(
    onTap: () {
      // Navigate to MainDetail page when product is tapped
      Navigator.push(
        ref.context,
        MaterialPageRoute(
          builder: (context) => MainDetail(productId: productModel.id!),
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Center(
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    uri_product_img + productModel.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tên sản phẩm
            Text(
              productModel.productName ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Giá bán và nhãn Sale
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sale!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatCurrency(productModel.priceSale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Giá gốc gạch ngang
            if (productModel.cost != null && productModel.cost! > 0)
              Text(
                formatCurrency(productModel.cost),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}