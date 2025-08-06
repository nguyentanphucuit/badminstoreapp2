import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart';
import '../../data/model/product_viewmodel.dart';
//import '../../data/model/productmodel.dart';
import '../../data/model/cartitemmodel.dart';
import '../../page/mainpage.dart';
import '../shipping/shippingaddress.dart';
import '../../data/model/usermodel.dart';

class ProductCart extends ConsumerStatefulWidget {
  const ProductCart({Key? key, this.user}) : super(key: key);
  final UserModel? user;
  @override
  _ProductCartState createState() => _ProductCartState();
}

class _ProductCartState extends ConsumerState<ProductCart> {
  // State để quản lý trạng thái loading cho tổng giá
  bool _isLoadingTotal = false;

  @override
  Widget build(BuildContext context) {
    //final cartItems = ref.watch(productsProvider.notifier).cartItems;
    final cartItems = ref.watch(cartItemsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8A87C), // Màu nền cam nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8A87C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Giỏ hàng${cartItems.isNotEmpty ? ' (${ref.watch(productsProvider.notifier).cartItemsCount})' : ''}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      // Thêm resizeToAvoidBottomInset: false để ngăn bàn phím đẩy nội dung lên
      resizeToAvoidBottomInset: false,
      body:
          cartItems.isEmpty
              ? _buildEmptyCart(context)
              : _buildCartWithItems(context, ref, cartItems),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon giỏ hàng rỗng
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                // Text thông báo
                const Text(
                  'Chưa thấy sản phẩm trong giỏ hàng của bạn',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                // Nút mua sắm ngay
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage(user: widget.user,)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2691E), // Màu cam đậm
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mua sắm ngay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartWithItems(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> cartItems,
  ) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(context, ref, cartItems[index], index);
              },
            ),
          ),
        ),
        // Thêm animation load ở đây (đặt bên ngoài Expanded để nó luôn ở dưới)
        if (_isLoadingTotal)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        _buildCartSummary(context, ref, cartItems),
      ],
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    CartItemModel cartItem,
    int index,
  ) {
    final TextEditingController quantityController = TextEditingController(
      text: cartItem.quantity.toString(),
    );

    // Thêm listener để cập nhật số lượng khi TextField thay đổi
    quantityController.addListener(() {
      int? newQuantity = int.tryParse(quantityController.text);
      if (newQuantity != null &&
          newQuantity > 0 &&
          newQuantity != cartItem.quantity) {
        // Debounce the update to avoid frequent rebuilds
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && newQuantity == int.tryParse(quantityController.text)) {
            _updateQuantity(ref, index, newQuantity);
          }
        });
      }
    });

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
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
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
                onPressed: () {
                  _showDeleteConfirmDialog(context, ref, index, cartItem);
                },
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.remove,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          _updateQuantity(ref, index, cartItem.quantity - 1);
                          // Cập nhật text của TextField khi nhấn nút
                          quantityController.text =
                              (cartItem.quantity - 1).toString();
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        height: 1.2,
                      ),
                      onTapOutside: (event) {
                        FocusScope.of(
                          context,
                        ).unfocus(); // Đóng bàn phím khi chạm ra ngoài
                      },
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.add, size: 18, color: Colors.grey[700]),
                      onPressed: () {
                        _updateQuantity(ref, index, cartItem.quantity + 1);
                        // Cập nhật text của TextField khi nhấn nút
                        quantityController.text =
                            (cartItem.quantity + 1).toString();
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

  Widget _buildCartSummary(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> cartItems,
  ) {
    final subtotal = ref.watch(productsProvider.notifier).cartTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng phụ:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                '${NumberFormat('###,###').format(subtotal)} đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Shipping
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí shipping:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                'Tính sau khi thanh toán',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${NumberFormat('###,###').format(subtotal)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm cập nhật số lượng và hiển thị animation
  void _updateQuantity(WidgetRef ref, int index, int newQuantity) async {
    setState(() {
      _isLoadingTotal = true; // Bắt đầu animation loading
    });
    // Giả lập một độ trễ để thấy animation loading
    await Future.delayed(const Duration(milliseconds: 300));

    ref
        .read(productsProvider.notifier)
        .updateCartItemQuantity(index, newQuantity);

    setState(() {
      _isLoadingTotal = false; // Kết thúc animation loading
    });
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    CartItemModel cartItem,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${cartItem.product.productName}" khỏi giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                ref.read(productsProvider.notifier).removeFromCart(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    //final double subtotal = ref.watch(productsProvider.notifier).cartTotal;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kiểm tra giỏ hàng trước khi thanh toán'),
          content: const Text(
            'Bạn có chắc chắn muốn tiếp tục thanh toán không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final subtotal =
                    ref.watch(productsProvider.notifier).cartTotal.toDouble();
                Navigator.of(dialogContext).pop(); // Đóng dialog trước
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ShippingAddressScreen(
                          subtotal: subtotal,
                          user: widget.user,
                        ),
                  ),
                );
              },
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );
  }
}

// Tạo alias cho EmptyCartPage để tương thích ngược
class EmptyCartPage extends ProductCart {
  const EmptyCartPage({Key? key, UserModel? user}) : super(key: key);
}
