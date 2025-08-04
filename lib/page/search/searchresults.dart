import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';

class SearchResultPage extends ConsumerStatefulWidget {
  final String searchQuery;
  
  const SearchResultPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  List<ProductModel> searchResults = [];
  bool isLoading = true;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    performSearch(widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      ReadData readData = ReadData();
      List<ProductModel> allProducts = await readData.loadData();
      
      // Tìm kiếm theo tên sản phẩm (không phân biệt hoa thường)
      List<ProductModel> results = allProducts
          .where((product) => 
              product.productName != null && 
              product.productName!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching products: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8), // Màu nền AppBar giống search.dart
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
          : searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Không có sản phẩm',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  // Sử dụng SingleChildScrollView để cuộn toàn bộ nội dung
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề "Kết quả tìm kiếm"
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Text(
                            'Kết quả tìm kiếm (${searchResults.length} sản phẩm)',
                            style: const TextStyle(
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
                              childAspectRatio: 0.62, // Sử dụng lại tỷ lệ từ search.dart
                            ),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              // Gọi itemGridView, giả định nó được định nghĩa ở nơi khác
                              return itemGridView(searchResults[index], ref);
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