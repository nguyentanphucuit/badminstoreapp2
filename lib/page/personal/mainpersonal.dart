import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../personal/setting.dart';
import '../personal/about.dart';
import '../personal/support.dart';
import '../../providers/auth_provider.dart';
import '../../data/model/user_profile_model.dart';
import '../../services/firestore_service.dart';

class MainPersonalPage extends ConsumerWidget {
  const MainPersonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildGuestView(context);
        }

        // Get user profile from Firestore
        return FutureBuilder<Map<String, dynamic>?>(
          future: ref.read(firestoreServiceProvider).getUserProfile(user.uid),
          builder: (context, snapshot) {
            final userProfileData = snapshot.data;
            final userProfile =
                userProfileData != null
                    ? UserProfile.fromMap(userProfileData)
                    : null;

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
                            child:
                                userProfile?.displayName != null &&
                                        userProfile!.displayName!.isNotEmpty
                                    ? Center(
                                      child: Text(
                                        _getInitials(userProfile!.displayName!),
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
                                  _getDisplayName(userProfile, user),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? 'No email',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'Giới thiệu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Trung tâm trợ giúp',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Cài đặt',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => _buildLoadingView(),
      error: (error, stack) => _buildErrorView(context, error),
    );
  }

  Widget _buildGuestView(BuildContext context) {
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
      body: const Center(
        child: Text(
          'Vui lòng đăng nhập để xem thông tin cá nhân',
          style: TextStyle(color: Color(0xFF8B4513), fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF8B4513), size: 64),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $error',
              style: const TextStyle(color: Color(0xFF8B4513), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getDisplayName(UserProfile? userProfile, dynamic user) {
    if (userProfile?.displayName != null &&
        userProfile!.displayName!.isNotEmpty) {
      return userProfile.displayName!;
    } else if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user.email != null && user.email!.isNotEmpty) {
      return user.email!;
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
              child: Icon(icon, color: const Color(0xFF8B4513), size: 20),
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
}
