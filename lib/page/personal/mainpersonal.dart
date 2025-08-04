import 'package:flutter/material.dart';
import '../personal/setting.dart';
import '../personal/about.dart';
import '../personal/support.dart';
import '../../data/model/usermodel.dart';

class MainPersonalPage extends StatelessWidget {
  final UserModel? user;
  
  const MainPersonalPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Trang cá nhân',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD2691E),
                      shape: BoxShape.circle,
                    ),
                    child: user?.fullname != null && user!.fullname!.isNotEmpty
                        ? Center(
                            child: Text(
                              _getInitials(user!.fullname!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDisplayName(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user?.email != null && user!.email!.isNotEmpty)
                          Text(
                            user!.email!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        if (user?.phonenumber != null && user!.phonenumber!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              user!.phonenumber!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // User Info Card (if user is logged in)
            if (user != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD2691E).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin tài khoản',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user!.username != null && user!.username!.isNotEmpty)
                      _buildInfoRow('Tên đăng nhập:', user!.username!),
                    if (user!.birthday != null && user!.birthday!.isNotEmpty)
                      _buildInfoRow('Ngày sinh:', _formatDate(user!.birthday!)),
                    _buildInfoRow('Loại tài khoản:', _getAccountType()),
                    _buildInfoRow('Trạng thái:', _getAccountStatus()),
                  ],
                ),
              ),

            // Order Button
            /*
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to orders page - có thể chuyển sang tab đơn hàng
                  // Hoặc điều hướng đến trang đơn hàng riêng
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2691E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Đơn hàng của tôi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ), */

            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () {
                // Navigate to personal info page
                _showUserInfoDialog(context);
              },
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Giới thiệu',
              onTap: () {
                // Navigate to about page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Trung tâm trợ giúp',
              onTap: () {
                // Navigate to help center
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Cài đặt',
              onTap: () {
                // Navigate to settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            /*
            if (user != null)
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ), */
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getDisplayName() {
    if (user == null) return 'Khách';
    
    if (user!.fullname != null && user!.fullname!.isNotEmpty) {
      return user!.fullname!;
    } else if (user!.email != null && user!.email!.isNotEmpty) {
      return user!.email!;
    } else if (user!.username != null && user!.username!.isNotEmpty) {
      return user!.username!;
    }
    
    return 'Người dùng';
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return 'U';
  }

  String _formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String _getAccountType() {
    if (user?.loginType == 'google') {
      return 'Google';
    } else if (user?.loginType == 'local') {
      return 'Tài khoản thường';
    }
    return 'Không xác định';
  }

  String _getAccountStatus() {
    if (user?.status == 1) {
      return 'Hoạt động';
    } else if (user?.status == 0) {
      return 'Bị khóa';
    }
    return 'Không xác định';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B4513),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B4513),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD2691E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8B4513),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B4513),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF8B4513),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    if (user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3),
          title: const Text(
            'Thông tin chi tiết',
            style: TextStyle(
              color: Color(0xFF8B4513),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*
              if (user!.id != null)
                _buildInfoRow('ID:', user!.id.toString()),*/
              if (user!.username != null && user!.username!.isNotEmpty)
                _buildInfoRow('Tên đăng nhập:', user!.username!),
              if (user!.fullname != null && user!.fullname!.isNotEmpty)
                _buildInfoRow('Họ tên:', user!.fullname!),
              if (user!.email != null && user!.email!.isNotEmpty)
                _buildInfoRow('Email:', user!.email!),
              if (user!.phonenumber != null && user!.phonenumber!.isNotEmpty)
                _buildInfoRow('Số điện thoại:', user!.phonenumber!),
              if (user!.birthday != null && user!.birthday!.isNotEmpty)
                _buildInfoRow('Ngày sinh:', _formatDate(user!.birthday!)),
              _buildInfoRow('Loại tài khoản:', _getAccountType()),
              _buildInfoRow('Trạng thái:', _getAccountStatus()),
              if (user!.googleId != null && user!.googleId!.isNotEmpty)
                _buildInfoRow('Google ID:', user!.googleId!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Color(0xFF8B4513)),
              ),
            ),
          ],
        );
      },
    );
  }
  /*
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3),
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(
              color: Color(0xFF8B4513),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất không?',
            style: TextStyle(color: Color(0xFF8B4513)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF8B4513)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to login screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }*/
}