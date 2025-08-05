import 'package:flutter/material.dart';
import 'login_with_firebase.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTruth = false;
  bool _agreeToPolicy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Nút quay lại
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF8B4513),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                // Tên shop (hình ảnh shopname.png)
                Image.asset(
                  'assets/images/shopname.png',
                  width: 200,
                  height: 60,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Đăng kí tài khoản',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),

                const SizedBox(height: 30),

                // Email
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  obscureText: false,
                ),

                const SizedBox(height: 16),

                // Tên đăng nhập
                _buildTextField(
                  controller: _usernameController,
                  hintText: 'Tên đăng nhập',
                  icon: Icons.person_outline,
                  obscureText: false,
                ),

                const SizedBox(height: 16),

                // Mật khẩu
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  onSuffixTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Nhập lại mật khẩu
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Nhập lại mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  isPassword: true,
                  onSuffixTap: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Checkbox 1
                CheckboxListTile(
                  title: const Text(
                    'Thông tin trên đúng với sự thật và tôi sẽ chịu trách nhiệm',
                    style: TextStyle(color: Color(0xFF8B4513), fontSize: 14),
                  ),
                  value: _agreeToTruth,
                  activeColor: Color(0xFFFF8C42),
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToTruth = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                // Checkbox 2
                CheckboxListTile(
                  title: const Text(
                    'Tôi đồng ý với chính sách bảo mật và điều khoản app',
                    style: TextStyle(color: Color(0xFF8B4513), fontSize: 14),
                  ),
                  value: _agreeToPolicy,
                  activeColor: Color(0xFFFF8C42),
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToPolicy = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 16), // Khoảng cách trước nút
                // Nút đăng ký
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
                      // Xử lý đăng ký
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginWithFirebaseScreen(),
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
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Hoặc đăng nhập với',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B4513),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 12),

                // Google login
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Google login handler
                    },
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    bool isPassword = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF8B4513), fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF8B4513).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF8B4513)),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF8B4513),
                    ),
                    onPressed: onSuffixTap,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
