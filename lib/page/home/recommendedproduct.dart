import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';

class RecommendedProductWidget extends ConsumerStatefulWidget {
  @override
  _RecommendedProductWidgetState createState() => _RecommendedProductWidgetState();
}

class _RecommendedProductWidgetState extends ConsumerState<RecommendedProductWidget> {
  PageController _pageController = PageController();
  Timer? _timer;
  List<ProductModel> recommendedProducts = [];
  bool isLoading = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadRecommendedProducts();
  }

  Future<void> loadRecommendedProducts() async {
    try {
      ReadData readData = ReadData();
      List<ProductModel> allProducts = await readData.loadData();
      
      // Lọc sản phẩm từ id 1 đến id 80
      List<ProductModel> filteredProducts = allProducts
          .where((product) => product.id != null && product.id! >= 1 && product.id! <= 80)
          .toList();
      
      // Random chọn 8 sản phẩm
      Random random = Random();
      filteredProducts.shuffle(random);
      recommendedProducts = filteredProducts.take(8).toList();
      
      setState(() {
        isLoading = false;
      });
      
      startAutoScroll();
    } catch (e) {
      print('Error loading recommended products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void startAutoScroll() {
    if (recommendedProducts.length <= 2) return;
    
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        // Tính toán số trang (mỗi trang 2 sản phẩm)
        int maxPages = (recommendedProducts.length / 2).ceil();
        
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

    if (recommendedProducts.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Text('Không có sản phẩm được đề xuất'),
        ),
      );
    }

    // Chia sản phẩm thành các cặp (mỗi trang 2 sản phẩm)
    List<List<ProductModel>> productPairs = [];
    for (int i = 0; i < recommendedProducts.length; i += 2) {
      List<ProductModel> pair = [recommendedProducts[i]];
      if (i + 1 < recommendedProducts.length) {
        pair.add(recommendedProducts[i + 1]);
      }
      productPairs.add(pair);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề với nút refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sản phẩm đề xuất',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLoading = true;
                    currentPage = 0;
                  });
                  _timer?.cancel();
                  loadRecommendedProducts();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ),
            ],
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