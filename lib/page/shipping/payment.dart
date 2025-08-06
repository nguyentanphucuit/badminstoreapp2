import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shipping/orderconfirm.dart';
import '../../data/model/usermodel.dart';

class PaymentScreen extends StatefulWidget {
  final double subtotal;
  final UserModel? user;
  final Map<String, String>? shippingInfo;

  const PaymentScreen({
    Key? key,
    required this.subtotal,
    this.user,
    this.shippingInfo,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'momo'; // Default selected payment method

  // Constants
  static const double shippingFee = 20000; // Phí vận chuyển cố định

  // Calculated values
  double get total => widget.subtotal + shippingFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB382), // Màu cam nhạt
              Color(0xFFFF8C42), // Màu cam đậm
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B4513),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_shopname.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressStep(1, 'Giao hàng', true),
                    _buildProgressLine(true),
                    _buildProgressStep(2, 'Thanh toán', true),
                    _buildProgressLine(false),
                    _buildProgressStep(3, 'Xác nhận', false),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phương thức vận chuyển
                        const Text(
                          'PHƯƠNG THỨC VẬN CHUYỂN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Giao hàng tiêu chuẩn: ${NumberFormat('###,###').format(shippingFee)}đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Phương thức thanh toán
                        const Text(
                          'PHƯƠNG THỨC THANH TOÁN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Ví Momo
                        _buildPaymentOption(
                          'momo',
                          'assets/images/momo_icon_square_pinkbg_RGB.png',
                          'Ví Momo',
                        ),

                        const SizedBox(height: 12),

                        // VNPAY
                        _buildPaymentOption(
                          'vnpay',
                          'assets/images/vnpay_icon.png',
                          'VNPAY',
                        ),

                        const SizedBox(height: 12),

                        // Thanh toán bằng tiền mặt
                        _buildPaymentOption(
                          'cash',
                          'assets/images/cost_icon.png',
                          'Thanh toán bằng tiền mặt khi nhận hàng',
                        ),

                        const SizedBox(height: 30),

                        // Giá trị đơn hàng
                        const Text(
                          'GIÁ TRỊ ĐƠN HÀNG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Thành tiền',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('###,###').format(widget.subtotal)} vnđ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí vận chuyển',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('###,###').format(shippingFee)} đ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(
                                color: Color(0xFF8B4513),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng số tiền',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('###,###').format(total)}vnđ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Thanh toán button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8C42), Color(0xFFFF6B1A)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              /*
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderConfirmScreen(
                                    subtotal: widget.subtotal,
                                    shippingFee: shippingFee,
                                    total: total,
                                    paymentMethod: _selectedPaymentMethod,
                                  ),
                                ),
                              );*/
                              if (_selectedPaymentMethod == 'momo' ||
                                  _selectedPaymentMethod == 'vnpay') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Thanh toán đang được phát triển, vui lòng chọn phương thức COD (tiền mặt).',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              // Use shipping info from previous screen
                              final shippingInfo =
                                  widget.shippingInfo ??
                                  {
                                    'receiverName': 'User Name',
                                    'receiverPhone': 'User Phone',
                                    'shippingAddress': 'User Address',
                                  };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => OrderConfirmScreen(
                                        user: widget.user,
                                        subtotal: widget.subtotal,
                                        shippingInfo: shippingInfo,
                                        paymentMethod: _selectedPaymentMethod,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Thanh toán',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : const Color(0xFFFF8C42),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : const Color(0xFF8B4513),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Colors.green : Colors.grey.withOpacity(0.5),
    );
  }

  Widget _buildPaymentOption(String value, String iconPath, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            _selectedPaymentMethod = newValue!;
          });
        },
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.payment,
                      color: Color(0xFF8B4513),
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
              ),
            ),
          ],
        ),
        activeColor: Colors.red,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _processPayment() {
    // Xử lý thanh toán dựa trên phương thức đã chọn
    String paymentMethodText = '';
    switch (_selectedPaymentMethod) {
      case 'momo':
        paymentMethodText = 'Ví Momo';
        break;
      case 'vnpay':
        paymentMethodText = 'VNPAY';
        break;
      case 'cash':
        paymentMethodText = 'Thanh toán bằng tiền mặt khi nhận hàng';
        break;
    }

    _showSuccessSnackBar('Đã chọn phương thức thanh toán: $paymentMethodText');

    // Ở đây có thể navigate tới trang kiểm tra đơn hàng
    print('Selected payment method: $_selectedPaymentMethod');
    print('Processing payment...');
    print('Subtotal: ${widget.subtotal}');
    print('Shipping fee: $shippingFee');
    print('Total: $total');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
