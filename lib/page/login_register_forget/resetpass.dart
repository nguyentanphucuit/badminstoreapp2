import 'package:flutter/material.dart';
import 'login.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  // Biến để quản lý hiển thị mật khẩu
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    // Định nghĩa các màu sắc chính để dễ dàng quản lý
    const Color primaryColor = Color(0xFFF0903D);
    const Color backgroundColor = Color(0xFFF9A861);
    const Color textFieldColor = Color(0xFFFDE8D4);
    const Color iconColor = Color(0xFF8B572A);
    const Color textColor = Color(0xFF51341A);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB382),
            Color(0xFFFF8C42),
          ],
        ),
      ),
      // THAY ĐỔI 1: Bọc body bằng SafeArea để tránh các phần tử hệ thống (tai thỏ, status bar)
      child: SafeArea(
        // THAY ĐỔI 2: Bọc SingleChildScrollView bằng Center để căn giữa toàn bộ nội dung
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo và Tên cửa hàng
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/images/shopname.png',
                    height: 80, // Điều chỉnh chiều cao nếu cần
                  ),
                  const SizedBox(height: 40),

                  // Tiêu đề
                  const Text(
                    'Đổi mật khẩu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Trường nhập Mật khẩu mới
                  TextField(
                    obscureText: _isNewPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu mới',
                      hintStyle: const TextStyle(color: iconColor),
                      prefixIcon: const Icon(Icons.vpn_key_outlined, color: iconColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordObscured ? Icons.visibility_off : Icons.visibility,
                          color: iconColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordObscured = !_isNewPasswordObscured;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: textFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trường Nhập lại mật khẩu
                  TextField(
                    obscureText: _isConfirmPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'Nhập lại mật khẩu',
                      hintStyle: const TextStyle(color: iconColor),
                      prefixIcon: const Icon(Icons.vpn_key_outlined, color: iconColor),
                       suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                          color: iconColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: textFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF8C42),
                          Color(0xFFFF6B1A),
                        ],
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
                    // Nút Hoàn tất
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                        'Hoàn tất',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}