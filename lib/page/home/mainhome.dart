import 'package:flutter/material.dart';
import '../home/bestseller.dart';
import '../home/categorylist.dart';
import '../home/newproduct.dart';
import '../home/recommendedproduct.dart';
import '../home/slider.dart';

class MainHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sử dụng Scaffold để đặt màu nền cho toàn bộ trang
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sắp xếp lại thứ tự hiển thị theo yêu cầu
            CategoryList(),
            SliderWidget(),
            BestSellerWidget(),
            NewProductWidget(),
            RecommendedProductWidget(),
          ],
        ),
      ),
    );
  }
}