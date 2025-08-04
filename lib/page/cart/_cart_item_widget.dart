/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart'; // Đảm bảo đường dẫn đúng
import '../../data/model/cartitemmodel.dart'; // Đảm bảo đường dẫn đúng
//import '../../data/model/product_viewmodel.dart'; // Đảm bảo đường dẫn đúng

// Tạo một StatefulWidget riêng cho mỗi mục giỏ hàng
class _CartItemWidget extends ConsumerStatefulWidget {
  final CartItemModel cartItem;
  final int index;
  final Function(int) onUpdateQuantity; // Callback để cập nhật số lượng
  final VoidCallback onRemoveItem; // Callback để xóa sản phẩm

  const _CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.index,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
  }) : super(key: key);

  @override
  ConsumerState<_CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends ConsumerState<_CartItemWidget> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.cartItem.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật TextEditingController khi cartItem.quantity thay đổi từ bên ngoài
    // Điều này đảm bảo ô nhập liệu luôn hiển thị giá trị đúng nhất từ Riverpod
    if (widget.cartItem.quantity.toString() != _quantityController.text) {
      _quantityController.text = widget.cartItem.quantity.toString();
      // Di chuyển con trỏ về cuối để tránh nhảy khi số thay đổi
      _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy lại CartItemModel từ widget để đảm bảo nó luôn là dữ liệu mới nhất
    final cartItem = widget.cartItem;
    final index = widget.index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  '${uri_product_img}${cartItem.product.image}',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.product.productName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Original price (crossed out)
                    if (cartItem.product.cost != null)
                      Text(
                        '${NumberFormat('###,###').format(cartItem.product.cost)} đ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                    // Sale price
                    Text(
                      '${NumberFormat('###,###').format(cartItem.product.priceSale)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),

                    // Size (if available)
                    if (cartItem.size != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Size: ${cartItem.size}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onRemoveItem, // Sử dụng callback
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity controls and total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity controls
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          widget.onUpdateQuantity(cartItem.quantity - 1);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 60, // Increased width for better input
                    height: 32,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero, // Remove inner padding
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      onFieldSubmitted: (value) {
                        final newQuantity = int.tryParse(value);
                        if (newQuantity != null && newQuantity > 0) {
                          widget.onUpdateQuantity(newQuantity);
                        } else {
                          // Reset to current valid quantity if input is invalid
                          _quantityController.text = cartItem.quantity.toString();
                        }
                      },
                      // Dùng onChanged để cập nhật ngay lập tức khi người dùng nhập
                      // Tuy nhiên, cẩn thận với tần suất gọi updateQuantity
                      onChanged: (value) {
                        final newQuantity = int.tryParse(value);
                        if (newQuantity != null && newQuantity > 0 && newQuantity != cartItem.quantity) {
                          // Thêm debounce nếu cần để tránh cập nhật quá nhanh khi người dùng đang gõ
                          // Hiện tại, cập nhật ngay lập tức.
                          widget.onUpdateQuantity(newQuantity);
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        widget.onUpdateQuantity(cartItem.quantity + 1);
                      },
                    ),
                  ),
                ],
              ),

              // Item total
              Text(
                '${NumberFormat('###,###').format(cartItem.totalPrice)} đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} */