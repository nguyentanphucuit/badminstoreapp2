import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math'; // Import để sử dụng Random
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart'; // Giả định itemGridView được cung cấp từ đây
import 'searchresults.dart'; // Import trang kết quả tìm kiếm

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  List<ProductModel> suggestedProducts = [];
  bool isLoading = true;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    loadSuggestedProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadSuggestedProducts() async {
    try {
      ReadData readData = ReadData();
      List<ProductModel> allProducts = await readData.loadData();
      
      // Lọc sản phẩm từ id 1 đến id 80
      List<ProductModel> productsInRange = allProducts
          .where((product) => product.id != null && product.id! >= 1 && product.id! <= 80)
          .toList();

      // Lấy ngẫu nhiên 16 sản phẩm từ danh sách đã lọc
      if (productsInRange.isNotEmpty) {
        final random = Random();
        final List<ProductModel> shuffledProducts = List.from(productsInRange)..shuffle(random);
        suggestedProducts = shuffledProducts.take(16).toList();
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading suggested products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(searchQuery: query.trim()),
        ),
      );
    }
  }

  // itemGridView được giả định là một hàm hoặc widget được định nghĩa
  // trong productbody.dart hoặc một tệp được import bởi nó.
  // Nó không được định nghĩa trực tiếp trong SearchPage này.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8), // Màu nền AppBar trắng
        elevation: 0, // Bỏ đổ bóng
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Icon mũi tên quay lại
          onPressed: () {
            Navigator.of(context).pop(); // Quay lại trang trước
          },
        ),
        title: Container(
          height: 40, // Chiều cao của thanh tìm kiếm
          decoration: BoxDecoration(
            color: Colors.white, // Màu nền của thanh tìm kiếm
            borderRadius: BorderRadius.circular(8), // Bo tròn góc
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmitted,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm tên sản phẩm và nhãn hiệu', // Hint text
              hintStyle: TextStyle(color: Colors.orange), // Màu hint text
              border: InputBorder.none, // Bỏ border
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: Icon(Icons.search, color: Colors.black), // Icon tìm kiếm bên trong
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : suggestedProducts.isEmpty
              ? const Center(
                  child: Text('Không có sản phẩm gợi ý'),
                )
              : SingleChildScrollView(
                // Sử dụng SingleChildScrollView để cuộn toàn bộ nội dung
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề "Gợi ý sản phẩm"
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Text(
                            'Gợi ý sản phẩm', // Tiêu đề theo yêu cầu
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Grid hiển thị sản phẩm (2 cột)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16), // Thêm margin cho GridView
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn của GridView
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.62, // Sử dụng lại tỷ lệ từ newproduct.dart của bạn
                            ),
                            itemCount: suggestedProducts.length,
                            itemBuilder: (context, index) {
                              // Gọi itemGridView, giả định nó được định nghĩa ở nơi khác
                              return itemGridView(suggestedProducts[index], ref);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}