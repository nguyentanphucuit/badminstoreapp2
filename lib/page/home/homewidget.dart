import 'package:flutter/material.dart';
import '../home/mainhome.dart'; // Import MainHome
import '../search/search.dart';
import '../cart/productcart.dart';
import '../../data/model/usermodel.dart';

class HomeWidget extends StatelessWidget {
  final UserModel? user;

  const HomeWidget({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.shopping_cart, color: Colors.black), // Icon giỏ hàng
            onPressed: () {
              // Xử lý khi nhấn icon giỏ hàng
              Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmptyCartPage(user: user)),
                      );
            },
          ),
        ],
      ),
      body: MainHome(), // Truyền MainHome vào phần thân của Scaffold
    );
  }
}