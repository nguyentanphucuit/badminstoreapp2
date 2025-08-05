import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../../data/data/productsizedata.dart';
import '../../data/model/productsizemodel.dart';
import '../../data/data/racketdata.dart';
import '../../data/model/racketinfomodel.dart';
import '../../data/data/shoedata.dart';
import '../../data/model/shoeinfomodel.dart';
import '../../data/data/clothingdata.dart';
import '../../data/model/clothinginfomodel.dart';
import '../../data/data/bagaccessorydata.dart';
import '../../data/model/bagaccessorymodel.dart';
import '../../conf/const.dart';
import '../cart/productcart.dart';
import '../../data/model/product_viewmodel.dart';
import '../product/productbody.dart';
import '../../data/data/branddata.dart';
import '../../data/model/brandmodel.dart';
//import '../../data/model/cartitemmodel.dart';
import 'dart:math';

class MainDetail extends ConsumerStatefulWidget {
  final int productId;

  const MainDetail({Key? key, required this.productId}) : super(key: key);

  @override
  ConsumerState<MainDetail> createState() => _MainDetailState();
}

class _MainDetailState extends ConsumerState<MainDetail> {
  ProductModel? product;
  List<ProductSizeModel> productSizes = [];
  List<RacketInfoModel> racketInfos = [];
  List<ShoeInfoModel> shoeInfos = [];
  List<ClothingInfoModel> clothingInfos = [];
  List<BagAccessoryModel> bagAccessoryInfos = [];
  List<ProductModel> allProducts = [];
  bool isLoading = true;
  String? selectedSize;

  // State variable for quantity
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    loadProductData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  Future<void> _showQuantityInputDialog() async {
    final TextEditingController tempQuantityController = TextEditingController(
      text: _quantity.toString(),
    );

    final newQuantity = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take full height if needed
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Adjust padding when keyboard is open
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Nhập số lượng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: tempQuantityController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Số lượng',
                  ),
                  onSubmitted: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      Navigator.pop(context, parsed);
                    } else {
                      Navigator.pop(
                        context,
                        _quantity,
                      ); // Revert to current quantity if invalid
                    }
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        ); // Dismiss without changing quantity
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final parsed = int.tryParse(
                          tempQuantityController.text,
                        );
                        if (parsed != null && parsed > 0) {
                          Navigator.pop(context, parsed);
                        } else {
                          Navigator.pop(
                            context,
                            _quantity,
                          ); // Revert to current quantity if invalid
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (newQuantity != null) {
      setState(() {
        _quantity = newQuantity;
      });
    }
  }

  Future<void> loadProductData() async {
    try {
      // Load all data
      final products = await ReadData().loadData();
      final sizes = await ProductSizeData().loadData();
      final rackets = await RacketData().loadData();
      final shoes = await ShoeData().loadData();
      final clothing = await ClothingData().loadData();
      final bagAccessory = await BagAccessoryData().loadData();

      setState(() {
        allProducts = products;
        product = products.firstWhere((p) => p.id == widget.productId);
        productSizes =
            sizes.where((s) => s.productId == widget.productId).toList();
        racketInfos =
            rackets.where((r) => r.productId == widget.productId).toList();
        shoeInfos =
            shoes.where((s) => s.productId == widget.productId).toList();
        clothingInfos =
            clothing.where((c) => c.productId == widget.productId).toList();
        bagAccessoryInfos =
            bagAccessory.where((b) => b.productId == widget.productId).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int getProductType() {
    if (product?.categoryId == null) return 0;

    // Determine product type based on category
    // 1: Racket, 2: Shoes, 3: Clothing, 4: Bag/Accessory
    int categoryId = product!.categoryId!;

    if (categoryId == 1) return 2; // Racket
    if (categoryId == 2) return 1; // Shoes
    if (categoryId >= 3 && categoryId <= 5) return 3; // Clothing
    if (categoryId >= 6 && categoryId <= 8) return 4; // Bag/Accessory

    return 0; // Unknown category
  }

  bool isProductInFavorites() {
    final favorites = ref.watch(productsProvider)['favorite']!;
    return favorites.any((p) => p.id == product?.id);
  }

  // Thêm các method này vào class _MainDetailState:
  void _addToCart() {
    // Kiểm tra nếu sản phẩm có size nhưng chưa chọn
    if (productSizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn size trước khi thêm vào giỏ hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (product != null) {
      ref
          .read(productsProvider.notifier)
          .addToCart(product!, _quantity, selectedSize);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${_quantity} sản phẩm vào giỏ hàng'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _buyNow() {
    // Kiểm tra nếu sản phẩm có size nhưng chưa chọn
    if (productSizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn size trước khi mua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (product != null) {
      // Thêm vào giỏ hàng trước
      ref
          .read(productsProvider.notifier)
          .addToCart(product!, _quantity, selectedSize);

      // Chuyển đến trang giỏ hàng
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProductCart()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return Scaffold(body: Center(child: Text('Product not found')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.brown),
            onPressed: () {
              // Handle cart action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmptyCartPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderProduct(product: product!),
            if (productSizes.isNotEmpty)
              SizeSelector(
                sizes: productSizes,
                selectedSize: selectedSize,
                onSizeSelected: (size) {
                  setState(() {
                    selectedSize = size;
                  });
                },
              ),
            ProductInfo(
              product: product!,
              productType: getProductType(),
              racketInfo: racketInfos.isNotEmpty ? racketInfos.first : null,
              shoeInfo: shoeInfos.isNotEmpty ? shoeInfos.first : null,
              clothingInfo:
                  clothingInfos.isNotEmpty ? clothingInfos.first : null,
              bagAccessoryInfo:
                  bagAccessoryInfos.isNotEmpty ? bagAccessoryInfos.first : null,
            ),
            RecommendedProducts(
              currentProductId: widget.productId,
              allProducts: allProducts,
            ),
            SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.remove, size: 20),
                onPressed: _decrementQuantity, // Call decrement function
              ),
            ),
            GestureDetector(
              // Wrap with GestureDetector to open input dialog
              onTap: _showQuantityInputDialog,
              child: Container(
                width: 60,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Add decoration to make it look like an input field
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _quantity.toString(), // Display current quantity
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: _incrementQuantity, // Call increment function
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _addToCart();
                },
                child: Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _buyNow();
                },
                child: Text(
                  'Mua ngay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// headerproduct.dart
class HeaderProduct extends ConsumerWidget {
  final ProductModel product;

  const HeaderProduct({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(productsProvider)['favorite']!;
    final isInFavorites = favorites.any((p) => p.id == product.id);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: double.infinity,
            height: 200,
            child: Image.asset(
              '${uri_product_img}${product.image}',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),

          // Product Name
          Text(
            product.productName ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 8),

          // Product Code and Heart Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã: ${product.code ?? ''}',
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isInFavorites = ref
                      .watch(productsProvider)['favorite']!
                      .any((p) => p.id == product.id);

                  return IconButton(
                    icon: Icon(
                      isInFavorites ? Icons.favorite : Icons.favorite_border,
                      color: isInFavorites ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      try {
                        if (isInFavorites) {
                          // Remove from favorites
                          final index = ref
                              .read(productsProvider)['favorite']!
                              .indexWhere((p) => p.id == product.id);
                          if (index != -1) {
                            await ref
                                .read(productsProvider.notifier)
                                .removeFromFavorite(index);
                          }
                        } else {
                          // Add to favorites
                          await ref
                              .read(productsProvider.notifier)
                              .addToFavorite(product);
                        }
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // Brand and Status
          Row(
            children: [
              Text(
                'Thương hiệu: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              /*
              Text(
                //'Brand ${product.brandId ?? ''}',
                product.brandId.toString(),
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ), */
              FutureBuilder<List<BrandModel>>(
                future: BrandData().loadData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Đang tải...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Lỗi tải thương hiệu',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    );
                  } else {
                    final brandList = snapshot.data!;
                    final brand = brandList.firstWhere(
                      (b) => b.id == product.brandId,
                      orElse: () => BrandModel(brandName: 'Không rõ'),
                    );
                    return Text(
                      brand.brandName ?? 'Không rõ',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    );
                  }
                },
              ),

              Text(
                ' | Tình trạng: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                product.status == 1 ? 'Còn hàng' : 'Hết hàng',
                style: TextStyle(
                  fontSize: 14,
                  color: product.status == 1 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          // Giá gốc gạch ngang
          Text(
            '${product.cost?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          // Price
          Text(
            '${product.priceSale?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),

          // Rating and Reviews
          /*
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(Icons.star_border, size: 16, color: Colors.grey);
                }),
              ),
              Text(' (0) | Đã bán 195', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),*/
        ],
      ),
    );
  }
}

// size.dart
class SizeSelector extends StatelessWidget {
  final List<ProductSizeModel> sizes;
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelector({
    Key? key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn Size:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                sizes.map((size) {
                  bool isAvailable = size.status == 1;
                  bool isSelected = selectedSize == size.size;

                  return GestureDetector(
                    onTap:
                        isAvailable ? () => onSizeSelected(size.size!) : null,
                    child: Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isAvailable
                                ? (isSelected ? Colors.orange : Colors.white)
                                : Colors.grey[300],
                        border: Border.all(
                          color:
                              isAvailable
                                  ? (isSelected ? Colors.orange : Colors.grey)
                                  : Colors.grey[400]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        size.size ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isAvailable
                                  ? (isSelected ? Colors.white : Colors.black)
                                  : Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// info.dart
class ProductInfo extends StatelessWidget {
  final ProductModel product;
  final int productType;
  final RacketInfoModel? racketInfo;
  final ShoeInfoModel? shoeInfo;
  final ClothingInfoModel? clothingInfo;
  final BagAccessoryModel? bagAccessoryInfo;

  const ProductInfo({
    Key? key,
    required this.product,
    required this.productType,
    this.racketInfo,
    this.shoeInfo,
    this.clothingInfo,
    this.bagAccessoryInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Information
          Text(
            'Thông tin sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 12),

          // Different info based on product type
          if (productType == 1) // Shoes
            _buildShoeInfo(),
          if (productType == 2) // Racket
            _buildRacketInfo(),
          if (productType == 3) // Clothing
            _buildClothingInfo(),
          if (productType == 4) // Bag/Accessory
            _buildBagAccessoryInfo(),
        ],
      ),
    );
  }

  Widget _buildShoeInfo() {
    if (shoeInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Size', shoeInfo!.size ?? 'N/A'),
        _buildInfoRow('Thân giày/ Upper', shoeInfo!.thanGiay ?? 'N/A'),
        _buildInfoRow('Đế giữa/ Midsole', shoeInfo!.deGiua ?? 'N/A'),
        _buildInfoRow('Đế ngoài/ Outsole', shoeInfo!.deNgoai ?? 'N/A'),
        _buildInfoRow(
          'Bên trong/ Inner materials',
          shoeInfo!.benTrong ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildRacketInfo() {
    if (racketInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Chất liệu', racketInfo!.chatLieu ?? 'N/A'),
        _buildInfoRow('Trọng lượng', racketInfo!.trongLuong ?? 'N/A'),
        _buildInfoRow('Chu vi cán vợt', racketInfo!.chuViCan ?? 'N/A'),
        _buildInfoRow('Chiều dài vợt', racketInfo!.chieuDaiVot ?? 'N/A'),
        _buildInfoRow('Chiều dài cán vợt', racketInfo!.chieuDaiCan ?? 'N/A'),
      ],
    );
  }

  Widget _buildClothingInfo() {
    if (clothingInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Size', clothingInfo!.size ?? 'N/A'),
        _buildInfoRow('Chất liệu', clothingInfo!.chatLieu ?? 'N/A'),
        _buildInfoRow('Thiết kế', clothingInfo!.thietKe ?? 'N/A'),
        _buildInfoRow('Kiểu loại', clothingInfo!.kieuLoai ?? 'N/A'),
        _buildInfoRow('Tính năng', clothingInfo!.tinhNang ?? 'N/A'),
      ],
    );
  }

  Widget _buildBagAccessoryInfo() {
    if (bagAccessoryInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Thương hiệu', bagAccessoryInfo!.thuongHieu ?? 'N/A'),
        _buildInfoRow('Màu sắc', bagAccessoryInfo!.mauSac ?? 'N/A'),
        _buildInfoRow('Kích thước', bagAccessoryInfo!.kichThuoc ?? 'N/A'),
        _buildInfoRow('Chất liệu', bagAccessoryInfo!.chatLieu ?? 'N/A'),
        _buildInfoRow('Tính năng', bagAccessoryInfo!.tinhNang ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// recommend.dart
class RecommendedProducts extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  final int currentProductId;
  final List<ProductModel> allProducts;

  const RecommendedProducts({
    Key? key,
    required this.currentProductId,
    required this.allProducts,
  }) : super(key: key);

  @override
  ConsumerState<RecommendedProducts> createState() =>
      _RecommendedProductsState(); // Changed to ConsumerState
}

class _RecommendedProductsState extends ConsumerState<RecommendedProducts> {
  // Changed to ConsumerState
  List<ProductModel> _displayedRecommendedProducts = [];

  @override
  void initState() {
    super.initState();
    _refreshProducts(); // Initial load of recommended products
  }

  void _refreshProducts() {
    final eligibleProducts =
        widget.allProducts
            .where((product) => product.id != widget.currentProductId)
            .toList();

    // Shuffle the list to get random products
    eligibleProducts.shuffle(Random());

    // Take up to 6 products
    setState(() {
      _displayedRecommendedProducts = eligibleProducts.take(6).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedRecommendedProducts.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Use Row to place text and icon on the same line
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribute space
            children: [
              Text(
                'Gợi ý cho bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              IconButton(
                // Refresh Icon Button
                icon: Icon(Icons.refresh, color: Colors.orange),
                onPressed: _refreshProducts,
              ),
            ],
          ),
          SizedBox(height: 16), // Space between button and grid
          GridView.builder(
            shrinkWrap: true, // Important for nested scrollables
            physics:
                NeverScrollableScrollPhysics(), // Disable internal scrolling
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 products per row
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.56, // Adjust as needed to fit content
            ),
            itemCount: _displayedRecommendedProducts.length,
            itemBuilder: (context, index) {
              return itemGridView(
                _displayedRecommendedProducts[index],
                ref,
              ); // Use itemGridView here
            },
          ),
        ],
      ),
    );
  }
}
