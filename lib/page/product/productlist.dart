/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/productmodel.dart';
import '../../data/data/productdata.dart';
import 'productbody.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    try {
      ReadData readData = ReadData();
      List<ProductModel> loadedProducts = await readData.loadData();
      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text(
                    'Không có sản phẩm nào',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 cột
                      childAspectRatio: 0.7, // Tỷ lệ width/height
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return itemGridView(products[index], ref);
                    },
                  ),
                ),
    );
  }
}

// Widget riêng để hiển thị sản phẩm có ID = 1
class SingleProductWidget extends ConsumerStatefulWidget {
  const SingleProductWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<SingleProductWidget> createState() => _SingleProductWidgetState();
}

class _SingleProductWidgetState extends ConsumerState<SingleProductWidget> {
  ProductModel? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  void loadProduct() async {
    try {
      ReadData readData = ReadData();
      List<ProductModel> products = await readData.loadData();
      
      // Tìm sản phẩm có ID = 1
      ProductModel? foundProduct;
      for (var p in products) {
        if (p.id == 1) {
          foundProduct = p;
          break;
        }
      }
      
      setState(() {
        product = foundProduct;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (product == null || product!.id == null) {
      return const Center(
        child: Text(
          'Không tìm thấy sản phẩm có ID = 1',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return Center(
      child: SizedBox(
        width: 200,
        child: itemGridView(product!, ref),
      ),
    );
  }
}*/