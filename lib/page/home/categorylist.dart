import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/data/categorydata.dart';
import '../../data/model/categorymodel.dart';
import '../../conf/const.dart';
import '../../page/category/maincategory.dart'; // Import MainCategoryPage

class CategoryList extends StatefulWidget {
  final Function(int)? onCategorySelected; // Thêm callback để thông báo danh mục được chọn

  const CategoryList({Key? key, this.onCategorySelected}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  PageController _pageController = PageController();
  Timer? _timer;
  List<CategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      CategoryData categoryData = CategoryData();
      categories = await categoryData.loadData();
      setState(() {
        isLoading = false;
      });
      startAutoScroll();
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void startAutoScroll() {
    if (categories.length <= 4) return; // Không cần cuộn nếu ít hơn hoặc bằng 4 danh mục
    
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        
        // Tính toán số trang tối đa (8 danh mục, hiển thị 4 mỗi trang)
        int maxPages = (categories.length / 4).ceil();
        
        if (nextPage >= maxPages) {
          // Quay lại trang đầu tiên
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // Chuyển sang trang tiếp theo
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildCategoryItem(CategoryModel category) {
    return GestureDetector( // Bọc bằng GestureDetector để xử lý sự kiện click
      onTap: () {
        if (widget.onCategorySelected != null) {
          widget.onCategorySelected!(category.id!); // Gọi callback nếu có
        } else {
          // Nếu không có callback (ví dụ: khi CategoryList được dùng độc lập),
          // thì điều hướng đến MainCategoryPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainCategoryPage(initialCategoryId: category.id!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container cho hình tròn
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5C0), // Màu nền beige như trong hình
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  '$uri_category_img${category.image}',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.category,
                      size: 30,
                      color: Colors.brown,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tên danh mục
            Text(
              category.categoryName ?? '',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.brown[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryPage(List<CategoryModel> pageCategories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: pageCategories.map((category) => 
        Expanded(child: buildCategoryItem(category))
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 120,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        height: 120,
        child: const Center(
          child: Text('Không có danh mục nào'),
        ),
      );
    }

    // Chia danh mục thành các trang (mỗi trang 4 danh mục)
    List<List<CategoryModel>> pages = [];
    for (int i = 0; i < categories.length; i += 4) {
      pages.add(categories.sublist(i, i + 4 > categories.length ? categories.length : i + 4));
    }

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return buildCategoryPage(pages[index]);
        },
      ),
    );
  }
}