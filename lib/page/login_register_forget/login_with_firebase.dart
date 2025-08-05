import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'register_with_firebase.dart';
import 'forget.dart';
import '../mainpage.dart';

class LoginWithFirebaseScreen extends ConsumerStatefulWidget {
  const LoginWithFirebaseScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginWithFirebaseScreen> createState() =>
      _LoginWithFirebaseScreenState();
}

class _LoginWithFirebaseScreenState
    extends ConsumerState<LoginWithFirebaseScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Show success message
      if (mounted) {
        _showSnackBar('Đăng nhập thành công!', isSuccess: true);
      }

      // Navigation will be handled by the AuthWrapper
      // No need to navigate manually here
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Đăng nhập thất bại';

        // Parse Firebase Auth errors
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'Không tìm thấy tài khoản với email này.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Mật khẩu không đúng.';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'Tài khoản này đã bị vô hiệu hóa.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Email không hợp lệ.';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'Tài khoản này đã bị vô hiệu hóa.';
        } else {
          errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
        }

        _showSnackBar(errorMessage);
        print('Login error details: $e'); // Debug print for exact error
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        duration: Duration(seconds: isSuccess ? 2 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No need to listen to auth state changes here
    // The AuthWrapper will handle navigation based on auth state

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // Logo
                          Image.asset(
                            'assets/images/logo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 16),

                          // Shop name image
                          Image.asset(
                            'assets/images/shopname.png',
                            width: 220,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 40),

                          // Title
                          const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: Color(0xFF8B4513),
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8B4513),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                color: Color(0xFF8B4513),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Mật khẩu',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF8B4513),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF8B4513),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
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
                                        'Đăng nhập',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Debug button (temporary)
                          TextButton(
                            onPressed: () {
                              final currentUser = ref.read(authProvider).value;
                              final isEmailVerified =
                                  ref
                                      .read(authProvider.notifier)
                                      .isEmailVerified;
                              print('Debug: Current user: ${currentUser?.uid}');
                              print('Debug: Email verified: $isEmailVerified');
                              _showSnackBar(
                                'User: ${currentUser?.uid ?? "null"}, Verified: $isEmailVerified',
                              );
                            },
                            child: const Text(
                              'Debug Auth State',
                              style: TextStyle(
                                color: Color(0xFF8B4513),
                                fontSize: 12,
                              ),
                            ),
                          ),

                          // Forgot password
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                color: Color(0xFF8B4513),
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Chưa có tài khoản? ',
                                style: TextStyle(
                                  color: Color(0xFF8B4513),
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const RegisterWithFirebaseScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Đăng ký',
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
              );
            },
          ),
        ),
      ),
    );
  }
}
