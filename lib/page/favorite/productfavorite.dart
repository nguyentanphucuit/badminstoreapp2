import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart';
import '../../data/model/product_viewmodel.dart';
import '../../data/model/productmodel.dart';
import '../detail/maindetail.dart';

class ProductFavorite extends ConsumerWidget {
  const ProductFavorite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(productsProvider)['favorite']!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Sản phẩm yêu thích',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
          ),
        ),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm yêu thích nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return itemListView(context, favorites[index], ref, index);
                },
              ),
            ),
    );
  }

  Widget itemListView(BuildContext context,ProductModel productModel, WidgetRef ref, int index) {
    return InkWell( // Wrap with InkWell for tap functionality and visual feedback
      onTap: () {
        // Navigate to MainDetail when the item is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainDetail(productId: productModel.id!), // Pass product ID
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                '${uri_product_img}${productModel.image}',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productModel.productName ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  // Giá gốc bị gạch ngang
                  if (productModel.cost != null)
                    Text(
                      '${NumberFormat('#,###').format(productModel.cost)} đ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  // Giá sale màu orange
                  if (productModel.priceSale != null)
                    Text(
                      '${NumberFormat('#,###').format(productModel.priceSale)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                ref.read(productsProvider.notifier).removeFromFavorite(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}