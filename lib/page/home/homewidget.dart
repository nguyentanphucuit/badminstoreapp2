import 'package:flutter/material.dart';
import '../home/mainhome.dart'; // Import MainHome
import '../search/search.dart';
import '../cart/productcart.dart';

class HomeWidget extends StatelessWidget {
  final dynamic user; // Changed to dynamic to accept null

  const HomeWidget({Key? key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('HomeWidget: Building home page'); // Debug log
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8), // Màu nền của AppBar
        elevation: 0, // Bỏ đổ bóng của AppBar
        leading: IconButton(
          icon: Icon(Icons.search, color: Colors.black), // Icon tìm kiếm
          onPressed: () {
            // Xử lý khi nhấn icon tìm kiếm
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),
        title: Image.asset(
          'assets/images/logo.png', // Đường dẫn đến logo
          height: 40, // Chiều cao của logo
        ),
        centerTitle: true, // Căn giữa logo
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ), // Icon giỏ hàng
            onPressed: () {
              // Xử lý khi nhấn icon giỏ hàng
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCart()),
              );
            },
          ),
        ],
      ),
      body: MainHome(), // Truyền MainHome vào phần thân của Scaffold
    );
  }
}
