import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';

class NewProductWidget extends ConsumerStatefulWidget {
  @override
  _NewProductWidgetState createState() => _NewProductWidgetState();
}

class _NewProductWidgetState extends ConsumerState<NewProductWidget> {
  List<ProductModel> newProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNewProducts();
  }

  Future<void> loadNewProducts() async {
    try {
      ReadData readData = ReadData();
      List<ProductModel> allProducts = await readData.loadData();
      
      // Lọc sản phẩm từ id 69 đến id 80
      newProducts = allProducts
          .where((product) => product.id != null && product.id! >= 1 && product.id! <= 12)
          .toList();
      
      // Sắp xếp theo id để đảm bảo thứ tự
      newProducts.sort((a, b) => a.id!.compareTo(b.id!));
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading new products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (newProducts.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text('Không có sản phẩm mới'),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            'Sản phẩm mới',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          
          // Grid hiển thị sản phẩm (2 cột)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.62, // Điều chỉnh tỷ lệ chiều cao/rộng
            ),
            itemCount: newProducts.length,
            itemBuilder: (context, index) {
              return itemGridView(newProducts[index], ref);
            },
          ),
        ],
      ),
    );
  }
}