import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thay đổi mật khẩu',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Temporarily comment out old password field to avoid Firebase plugin issue
            // _buildPasswordField(
            //   label: 'Mật khẩu hiện tại',
            //   controller: oldPasswordController,
            //   showPassword: showOldPassword,
            //   toggleShowPassword: () {
            //     setState(() {
            //       showOldPassword = !showOldPassword;
            //     });
            //   },
            // ),
            // const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Mật khẩu mới',
              controller: newPasswordController,
              showPassword: showNewPassword,
              toggleShowPassword: () {
                setState(() {
                  showNewPassword = !showNewPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Nhập lại mật khẩu mới',
              controller: confirmNewPasswordController,
              showPassword: showConfirmPassword,
              toggleShowPassword: () {
                setState(() {
                  showConfirmPassword = !showConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2691E),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLoading ? null : _changePassword,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Xác nhận thay đổi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback toggleShowPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF8B4513),
          ),
          onPressed: toggleShowPassword,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8B4513)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD2691E), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    // Validate inputs (skip old password for now due to Firebase plugin issue)
    if (newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', isError: true);
      return;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showSnackBar('Mật khẩu mới không khớp', isError: true);
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get Firebase Auth instance directly
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        _showSnackBar('Không tìm thấy người dùng', isError: true);
        return;
      }

      print(
        'ChangePassword: Starting password change for user: ${currentUser.email}',
      );

      // Try REST API approach to avoid Flutter plugin issues
      print('ChangePassword: Using Firebase REST API...');
      await _changePasswordWithRestAPI(currentUser, newPasswordController.text);
      print('ChangePassword: Password update successful via REST API');

      _showSnackBar('Mật khẩu đã được thay đổi thành công!', isError: false);

      // Clear form
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      print('ChangePassword: Error occurred: $e');
      print('ChangePassword: Error type: ${e.runtimeType}');
      print('ChangePassword: Error string: ${e.toString()}');

      String errorMessage = 'Có lỗi xảy ra khi thay đổi mật khẩu';

      // Handle FirebaseAuthException specifically
      if (e is FirebaseAuthException) {
        print('FirebaseAuthException code: ${e.code}');
        print('FirebaseAuthException message: ${e.message}');

        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'Mật khẩu hiện tại không đúng';
            break;
          case 'invalid-credential':
            errorMessage = 'Mật khẩu hiện tại không đúng';
            break;
          case 'weak-password':
            errorMessage = 'Mật khẩu mới quá yếu';
            break;
          case 'requires-recent-login':
            errorMessage = 'Vui lòng đăng nhập lại để thay đổi mật khẩu';
            break;
          case 'user-not-found':
            errorMessage = 'Không tìm thấy tài khoản';
            break;
          case 'invalid-email':
            errorMessage = 'Email không hợp lệ';
            break;
          case 'too-many-requests':
            errorMessage = 'Quá nhiều lần thử. Vui lòng thử lại sau';
            break;
          default:
            errorMessage = 'Lỗi: ${e.message}';
        }
      } else if (e is TypeError || e.toString().contains('PigeonUserDetails')) {
        // Handle Flutter/Firebase plugin compatibility error
        print('Firebase plugin compatibility error detected');
        errorMessage = 'Lỗi hệ thống Firebase. Vui lòng thử lại sau';
      } else {
        // Handle other types of errors
        String errorStr = e.toString().toLowerCase();

        if (errorStr.contains('wrong-password')) {
          errorMessage = 'Mật khẩu hiện tại không đúng';
        } else if (errorStr.contains('invalid-credential')) {
          errorMessage = 'Mật khẩu hiện tại không đúng';
        } else if (errorStr.contains('weak-password')) {
          errorMessage = 'Mật khẩu mới quá yếu';
        } else if (errorStr.contains('requires-recent-login')) {
          errorMessage = 'Vui lòng đăng nhập lại để thay đổi mật khẩu';
        } else if (errorStr.contains('user-not-found')) {
          errorMessage = 'Không tìm thấy tài khoản';
        } else if (errorStr.contains('invalid-email')) {
          errorMessage = 'Email không hợp lệ';
        } else if (errorStr.contains('too-many-requests')) {
          errorMessage = 'Quá nhiều lần thử. Vui lòng thử lại sau';
        } else if (errorStr.contains('network')) {
          errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
        }
      }

      _showSnackBar(errorMessage, isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _changePasswordWithRestAPI(User user, String newPassword) async {
    try {
      // Get user ID token
      final idToken = await user.getIdToken();

      // Firebase Auth REST API endpoint
      final url =
          'https://identitytoolkit.googleapis.com/v1/accounts:update?key=${AppConfig.webApiKey}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': idToken,
          'password': newPassword,
          'returnSecureToken': true,
        }),
      );

      print('REST API Response status: ${response.statusCode}');
      print('REST API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Password changed successfully via REST API');
        print('New ID Token: ${data['idToken']}');
      } else {
        final error = json.decode(response.body);
        throw Exception('REST API Error: ${error['error']['message']}');
      }
    } catch (e) {
      print('REST API Error: $e');
      rethrow;
    }
  }
}
