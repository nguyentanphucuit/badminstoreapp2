import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';

class BestSellerWidget extends ConsumerStatefulWidget {
  @override
  _BestSellerWidgetState createState() => _BestSellerWidgetState();
}

class _BestSellerWidgetState extends ConsumerState<BestSellerWidget> {
  PageController _pageController = PageController();
  Timer? _timer;
  List<ProductModel> bestSellerProducts = [];
  bool isLoading = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadBestSellerProducts();
  }

  Future<void> loadBestSellerProducts() async {
    try {
      ReadData readData = ReadData();
      List<ProductModel> allProducts = await readData.loadData();
      
      // Lọc sản phẩm từ id 1 đến id 8
      bestSellerProducts = allProducts
          .where((product) => product.id != null && product.id! >= 1 && product.id! <= 8)
          .toList();
      
      // Sắp xếp theo id để đảm bảo thứ tự
      bestSellerProducts.sort((a, b) => a.id!.compareTo(b.id!));
      
      setState(() {
        isLoading = false;
      });
      
      startAutoScroll();
    } catch (e) {
      print('Error loading best seller products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void startAutoScroll() {
    if (bestSellerProducts.length <= 2) return;
    
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        // Tính toán số trang (mỗi trang 2 sản phẩm)
        int maxPages = (bestSellerProducts.length / 2).ceil();
        
        setState(() {
          currentPage = (currentPage + 1) % maxPages;
        });
        
        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildProductPair(List<ProductModel> products) {
    return Row(
      children: products.map((product) => 
        Expanded(
          child: itemGridView(product, ref),
        )
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (bestSellerProducts.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Text('Không có sản phẩm bán chạy'),
        ),
      );
    }

    // Chia sản phẩm thành các cặp (mỗi trang 2 sản phẩm)
    List<List<ProductModel>> productPairs = [];
    for (int i = 0; i < bestSellerProducts.length; i += 2) {
      List<ProductModel> pair = [bestSellerProducts[i]];
      if (i + 1 < bestSellerProducts.length) {
        pair.add(bestSellerProducts[i + 1]);
      }
      productPairs.add(pair);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            'Sản phẩm bán chạy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          
          // PageView hiển thị các cặp sản phẩm
          Container(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: productPairs.length,
              itemBuilder: (context, index) {
                return buildProductPair(productPairs[index]);
              },
            ),
          ),
          
          SizedBox(height: 12),
          
          // Chỉ báo trang (dots)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productPairs.length,
                (index) => Container(
                  width: currentPage == index ? 12 : 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: currentPage == index 
                        ? Colors.orange 
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}