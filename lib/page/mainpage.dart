import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/favorite/productfavorite.dart';
import '../page/order/mainorder.dart';
import '../page/personal/mainpersonal.dart';
import '../page/home/homewidget.dart';
import '../providers/auth_provider.dart';
import '../data/model/product_viewmodel.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int currentIndex = 0;
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Don't load favorites here, wait for auth state to be ready
  }

  /// Loads favorites from Firebase Firestore when user is authenticated
  Future<void> _loadFavorites() async {
    try {
      print('Loading favorites...'); // Debug log
      await ref.read(productsProvider.notifier).loadFavoritesFromFirestore();
      setState(() {
        _favoritesLoaded = true;
      });
      print('Favorites loaded successfully'); // Debug log
    } catch (e) {
      print('Failed to load favorites: $e');
      // Don't set _favoritesLoaded to true if it failed
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        print('MainPage: Building with user: ${user?.uid}'); // Debug log

        // Load favorites if user is authenticated and not loaded yet
        if (user != null && !_favoritesLoaded) {
          print('User authenticated, loading favorites...'); // Debug log
          // Use Future.microtask to avoid calling setState during build
          Future.microtask(() => _loadFavorites());
        }

        // Danh sách các trang
        List<Widget> pages = [
          const HomeWidget(user: null), // Trang chủ - using proper HomeWidget
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
                'Error: $error',
                style: const TextStyle(color: Colors.red),
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
