import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../mainpage.dart';
import 'login_with_firebase.dart';

class RegisterWithFirebaseScreen extends ConsumerStatefulWidget {
  const RegisterWithFirebaseScreen({super.key});

  @override
  ConsumerState<RegisterWithFirebaseScreen> createState() =>
      _RegisterWithFirebaseScreenState();
}

class _RegisterWithFirebaseScreenState
    extends ConsumerState<RegisterWithFirebaseScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar('Vui lòng đồng ý với điều khoản sử dụng');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signUpWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );

      if (mounted) {
        // Clear form data
        _clearForm();

        // Show success message
        _showSnackBar('Đăng ký thành công!', isSuccess: true);

        // Navigate to home page after successful registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );

        print('Registration completed successfully - Navigated to home page');
      }
    } catch (e) {
      if (mounted) {
        // Check if user was actually created successfully despite the error
        final currentUser = ref.read(authProvider).value;
        if (currentUser != null) {
          // User was created successfully, show success message
          _showSnackBar('Đăng ký thành công!', isSuccess: true);
          print('Registration successful despite error: $e'); // Debug print

          // Clear form - AuthWrapper will handle navigation to main page
          _clearForm();
          return; // Don't show error message
        }

        // Only show error if user was not created successfully
        String errorMessage = 'Đăng ký thất bại';

        if (e.toString().contains('email-already-in-use')) {
          errorMessage =
              'Email này đã được sử dụng. Vui lòng sử dụng email khác hoặc đăng nhập.';
        } else if (e.toString().contains('weak-password')) {
          errorMessage =
              'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
        } else {
          errorMessage = 'Đăng ký thất bại: ${e.toString()}';
        }

        _showSnackBar(errorMessage);
        print('Registration error: $e'); // Add debug print
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _emailController.clear();
    _fullNameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _addressController.clear();
    setState(() {
      _agreeToTerms = false;
    });
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: isSuccess ? 4 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Đăng ký thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tài khoản của bạn đã được tạo thành công. Vui lòng kiểm tra email để xác thực tài khoản.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
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
            colors: [Color(0xFFFFB382), Color(0xFFFF8C42)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Back button
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

                  // Shop name
                  Image.asset(
                    'assets/images/shopname.png',
                    width: 200,
                    height: 60,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Đăng ký tài khoản',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Full Name
                  _buildTextField(
                    controller: _fullNameController,
                    hintText: 'Họ và tên',
                    icon: Icons.person_outline,
                    validator: (value) => _validateRequired(value, 'họ và tên'),
                  ),

                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 16),

                  // Phone
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) => _validateRequired(value, 'số điện thoại'),
                  ),

                  const SizedBox(height: 16),

                  // Address
                  _buildTextField(
                    controller: _addressController,
                    hintText: 'Địa chỉ',
                    icon: Icons.location_on_outlined,
                    validator: (value) => _validateRequired(value, 'địa chỉ'),
                  ),

                  const SizedBox(height: 16),

                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onPasswordVisibilityChanged: (value) {
                      setState(() {
                        _isPasswordVisible = value;
                      });
                    },
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Xác nhận mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onPasswordVisibilityChanged: (value) {
                      setState(() {
                        _isConfirmPasswordVisible = value;
                      });
                    },
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 20),

                  // Terms and conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF8B4513),
                      ),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(text: 'Tôi đồng ý với '),
                              TextSpan(
                                text: 'Điều khoản sử dụng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
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

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(
                          color: Color(0xFF8B4513),
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const LoginWithFirebaseScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
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
    bool isPassword = false,
    bool isPasswordVisible = false,
    Function(bool)? onPasswordVisibilityChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Color(0xFF8B4513), fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF8B4513), fontSize: 16),
          prefixIcon: Icon(icon, color: const Color(0xFF8B4513)),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF8B4513),
                    ),
                    onPressed: () {
                      onPasswordVisibilityChanged?.call(!isPasswordVisible);
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
