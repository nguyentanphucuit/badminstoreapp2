import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/favorite/productfavorite.dart';
import '../page/order/mainorder.dart';
import '../page/personal/mainpersonal.dart';
import '../providers/auth_provider.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        // Danh sách các trang
        List<Widget> pages = [
          const HomePage(), // Trang chủ - simplified for now
          const ProductFavorite(), // Trang yêu thích
          const MainOrder(), // Trang đơn hàng - will be updated to use Firebase Auth
          const ProfilePage(), // Trang cá nhân
        ];

        return Scaffold(
          body: pages[currentIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE8D5C4), // Màu nền bottom bar giống hình
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(
                0xFF8B4513,
              ), // Màu nâu đậm khi chọn
              unselectedItemColor: const Color(0xFF8B4513).withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Yêu thích',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Đơn hàng',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Cá nhân',
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              ),
            ),
          ),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Text(
                'Lỗi: $error',
                style: const TextStyle(color: Color(0xFF8B4513)),
              ),
            ),
          ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MainPersonalPage now handles Firebase Auth internally
    return const MainPersonalPage();
  }
}

// Simple home page placeholder
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Trang chủ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
