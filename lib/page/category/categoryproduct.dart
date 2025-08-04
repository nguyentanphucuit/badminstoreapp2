import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart'; // Giả định itemGridView được cung cấp từ đây

class CategoryProductWidget extends ConsumerStatefulWidget {
  final int categoryId; // Thêm tham số categoryId

  const CategoryProductWidget({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CategoryProductWidgetState createState() => _CategoryProductWidgetState();
}

class _CategoryProductWidgetState extends ConsumerState<CategoryProductWidget> {
  List<ProductModel> categoryProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategoryProducts();
  }

  // Khi categoryId thay đổi (ví dụ: người dùng chọn danh mục khác)
  @override
  void didUpdateWidget(covariant CategoryProductWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      // Tải lại sản phẩm nếu categoryId thay đổi
      loadCategoryProducts();
    }
  }

  Future<void> loadCategoryProducts() async {
    setState(() {
      isLoading = true; // Bắt đầu tải, hiển thị loading indicator
      categoryProducts = []; // Xóa dữ liệu cũ
    });
    try {
      ReadData readData = ReadData();
      List<ProductModel> allProducts = await readData.loadData();
      
      // Lọc sản phẩm theo categoryId
      categoryProducts = allProducts
          .where((product) => product.categoryId == widget.categoryId)
          .toList();
      
      // Sắp xếp theo id hoặc một tiêu chí nào đó nếu cần
      // categoryProducts.sort((a, b) => a.id!.compareTo(b.id!));
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading category products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // itemGridView được giả định là một hàm hoặc widget được định nghĩa
  // trong productbody.dart hoặc một tệp được import bởi nó.
  // Nó không được định nghĩa trực tiếp trong CategoryProductWidget này.

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (categoryProducts.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Text('Không có sản phẩm nào trong danh mục này'),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề "Sản phẩm nổi bật"
          const Text(
            'Sản phẩm nổi bật', // Tiêu đề theo yêu cầu
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          
          // Grid hiển thị sản phẩm (2 cột)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.62, // Sử dụng lại tỷ lệ từ newproduct.dart của bạn
            ),
            itemCount: categoryProducts.length,
            itemBuilder: (context, index) {
              // Gọi itemGridView, giả định nó được định nghĩa ở nơi khác
              return itemGridView(categoryProducts[index], ref);
            },
          ),
        ],
      ),
    );
  }
}