import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/categorylist.dart'; // Import CategoryList
import 'categoryproduct.dart'; // Import CategoryProductWidget

class MainCategoryPage extends ConsumerStatefulWidget {
  final int initialCategoryId; // ID danh mục ban đầu để hiển thị

  const MainCategoryPage({Key? key, required this.initialCategoryId}) : super(key: key);

  @override
  _MainCategoryPageState createState() => _MainCategoryPageState();
}

class _MainCategoryPageState extends ConsumerState<MainCategoryPage> {
  late int _selectedCategoryId; // Biến để lưu trữ ID danh mục hiện tại

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  // Hàm để cập nhật categoryId khi người dùng chọn danh mục khác
  void _onCategorySelected(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Màu nền AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Danh mục sản phẩm', // Tiêu đề trang
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hiển thị CategoryList
            // Truyền một callback để MainCategoryPage có thể nhận biết khi danh mục được chọn
            CategoryList(onCategorySelected: _onCategorySelected), 
            
            // Hiển thị CategoryProductWidget dựa trên danh mục đã chọn
            CategoryProductWidget(categoryId: _selectedCategoryId),
          ],
        ),
      ),
    );
  }
}