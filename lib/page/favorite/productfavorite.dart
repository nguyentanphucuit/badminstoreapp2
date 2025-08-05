import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart';
import '../../data/model/product_viewmodel.dart';
import '../../data/model/productmodel.dart';
import '../detail/maindetail.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../data/data/productdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFavorite extends ConsumerStatefulWidget {
  const ProductFavorite({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductFavorite> createState() => _ProductFavoriteState();
}

class _ProductFavoriteState extends ConsumerState<ProductFavorite> {
  bool _isLoading = false;
  String _debugInfo = '';
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Don't load immediately, wait for the widget to be built first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritesFromFirestore();
    });
  }

  /// Loads favorites from Firebase Firestore
  Future<void> _loadFavoritesFromFirestore() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Loading favorites...';
    });

    try {
      // Check if user is authenticated first
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _debugInfo = 'User not authenticated. Please log in first.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _debugInfo =
            'User authenticated: ${currentUser.uid}\nLoading favorites...';
      });

      // Load favorites using the provider
      await ref.read(productsProvider.notifier).loadFavoritesFromFirestore();

      print('Favorites loaded from Firestore successfully');
      setState(() {
        _debugInfo = 'Favorites loaded successfully!\nCheck the list below.';
        _favoritesLoaded = true; // Mark favorites as loaded
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tải danh sách yêu thích thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Failed to load favorites from Firestore: $e');
      setState(() {
        _debugInfo =
            'Error loading favorites: $e\nTap debug button for more info.';
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách yêu thích: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Debug function to manually test favorites retrieval
  Future<void> _debugFavorites() async {
    setState(() {
      _debugInfo = 'Debugging...';
    });

    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      String debugText = '=== AUTHENTICATION DEBUG ===\n';
      debugText += 'Current user: ${currentUser?.uid}\n';
      debugText += 'Email: ${currentUser?.email}\n';
      debugText += 'Is authenticated: ${currentUser != null}\n';

      if (currentUser != null) {
        debugText += '\n=== FIRESTORE DEBUG ===\n';

        // Test direct Firestore query for user's favorites document
        final firestore = FirebaseFirestore.instance;
        final userFavoritesDoc = firestore
            .collection('favorites')
            .doc(currentUser.uid);

        debugText += 'Querying user favorites document...\n';
        debugText += 'Document path: favorites/${currentUser.uid}\n';

        final docSnapshot = await userFavoritesDoc.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          debugText += 'Document exists: true\n';
          debugText += 'Document data:\n';
          debugText += '  userId: ${data['userId']}\n';
          debugText += '  productCodes: ${data['productCodes']}\n';
          debugText += '  createdAt: ${data['createdAt']}\n';
          debugText += '  updatedAt: ${data['updatedAt']}\n';

          List<dynamic> productCodes = List<dynamic>.from(
            data['productCodes'] ?? [],
          );
          debugText +=
              '\nFound ${productCodes.length} favorite product codes\n';

          // Test loading local product data
          debugText += '\n=== LOCAL PRODUCT DATA TEST ===\n';
          final readData = ReadData();
          final allProducts = await readData.loadData();
          debugText +=
              'Loaded ${allProducts.length} products from local JSON\n';

          // Test finding products by code in local data
          debugText += '\n=== PRODUCT MATCHING TEST ===\n';
          for (int i = 0; i < productCodes.length; i++) {
            final productCode = productCodes[i];
            debugText += 'Product Code ${i + 1}: $productCode\n';

            try {
              final product = allProducts.firstWhere(
                (p) => p.code == productCode,
                orElse: () => ProductModel(),
              );

              if (product.id != null) {
                debugText += '  Found in local data:\n';
                debugText += '    Name: ${product.productName}\n';
                debugText += '    Image: ${product.image}\n';
                debugText += '    Price: ${product.priceSale}\n';
                debugText += '    ID: ${product.id}\n';
              } else {
                debugText += '  Product not found in local data\n';
              }
            } catch (e) {
              debugText += '  Error finding product: $e\n';
            }
          }
        } else {
          debugText += 'Document exists: false\n';
          debugText += 'No favorites document found for this user\n';
        }

        // Test the service method
        debugText += '\n=== SERVICE METHOD TEST ===\n';
        final firestoreService = FirestoreService();

        // Test getting product codes
        final productCodes =
            await firestoreService.getUserFavoriteProductCodes();
        debugText +=
            'Service getProductCodes result: ${productCodes.length} codes\n';
        debugText += 'Product Codes: $productCodes\n';

        // Test the new approach: get codes and find in local data
        debugText += '\n=== NEW APPROACH TEST ===\n';
        if (productCodes.isNotEmpty) {
          final readData = ReadData();
          final allProducts = await readData.loadData();

          final favoriteProducts = <ProductModel>[];
          for (final productCode in productCodes) {
            final product = allProducts.firstWhere(
              (p) => p.code == productCode,
              orElse: () => ProductModel(),
            );

            if (product.id != null) {
              favoriteProducts.add(product);
            }
          }

          debugText +=
              'Found ${favoriteProducts.length} products in local data\n';
          for (int i = 0; i < favoriteProducts.length; i++) {
            final favorite = favoriteProducts[i];
            debugText +=
                '${i + 1}. ${favorite.productName} (Code: ${favorite.code}, ID: ${favorite.id})\n';
          }
        }

        // Test state management
        debugText += '\n=== STATE MANAGEMENT TEST ===\n';
        final stateFavorites =
            ref.read(productsProvider)['favorite'] as List<ProductModel>;
        debugText += 'State favorites count: ${stateFavorites.length}\n';

        for (int i = 0; i < stateFavorites.length; i++) {
          final favorite = stateFavorites[i];
          debugText +=
              '${i + 1}. ${favorite.productName} (Code: ${favorite.code}, ID: ${favorite.id})\n';
        }
      } else {
        debugText += 'No user authenticated\n';
        debugText += 'Please log in first\n';
      }

      setState(() {
        _debugInfo = debugText;
      });

      print('Debug info: $debugText');
    } catch (e) {
      setState(() {
        _debugInfo = 'Debug error: $e';
      });
      print('Debug error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch authentication state
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        // If user is authenticated and favorites haven't been loaded yet, load them
        if (user != null && !_favoritesLoaded && !_isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadFavoritesFromFirestore();
          });
        }

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
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.brown[800]),
                onPressed: _loadFavoritesFromFirestore,
                tooltip: 'Làm mới danh sách yêu thích',
              ),
              IconButton(
                icon: Icon(Icons.bug_report, color: Colors.brown[800]),
                onPressed: _debugFavorites,
                tooltip: 'Debug favorites',
              ),
            ],
          ),
          body: Column(
            children: [
              // Debug info section
              if (_debugInfo.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _debugInfo,
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child:
                    user == null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Vui lòng đăng nhập để xem danh sách yêu thích',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : _isLoading
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Đang tải danh sách yêu thích...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                        : favorites.isEmpty
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
                              SizedBox(height: 8),
                              Text(
                                'Hãy thêm sản phẩm vào danh sách yêu thích',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadFavoritesFromFirestore,
                                icon: Icon(Icons.refresh),
                                label: Text('Làm mới'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                        : SafeArea(
                          child: ListView.builder(
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              return itemListView(
                                context,
                                favorites[index],
                                ref,
                                index,
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        );
      },
      loading:
          () => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang kiểm tra đăng nhập...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Lỗi: $error',
                    style: TextStyle(fontSize: 16, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget itemListView(
    BuildContext context,
    ProductModel productModel,
    WidgetRef ref,
    int index,
  ) {
    return InkWell(
      // Wrap with InkWell for tap functionality and visual feedback
      onTap: () {
        // Navigate to MainDetail when the item is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MainDetail(productId: productModel.id!), // Pass product ID
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
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/products/${productModel.image}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 15),
            // Product Details
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
            // Remove from favorites button
            Consumer(
              builder: (context, ref, child) {
                return IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    try {
                      await ref
                          .read(productsProvider.notifier)
                          .removeFromFavorite(index);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa khỏi danh sách yêu thích'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
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
      ),
    );
  }
}
