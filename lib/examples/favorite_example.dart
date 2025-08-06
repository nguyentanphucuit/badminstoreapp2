import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/productmodel.dart';
import '../services/favorite_service.dart';

/// Example widget demonstrating how to use the FavoriteService
class FavoriteExample extends ConsumerStatefulWidget {
  const FavoriteExample({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoriteExample> createState() => _FavoriteExampleState();
}

class _FavoriteExampleState extends ConsumerState<FavoriteExample> {
  List<ProductModel> _favorites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Loads favorites from Firebase Firestore
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoriteService = ref.read(favoriteServiceProvider);
      final favorites = await favoriteService.getUserFavorites();

      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Adds a sample product to favorites
  Future<void> _addSampleToFavorites() async {
    try {
      final favoriteService = ref.read(favoriteServiceProvider);

      // Create a sample product
      final sampleProduct = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch,
        productName: 'Sample Product ${DateTime.now().millisecondsSinceEpoch}',
        priceSale: 500000,
        cost: 600000,
        image: 'sample_product.jpg',
        code: 'SAMPLE001',
      );

      await favoriteService.addToFavorites(sampleProduct.id.toString());

      // Reload favorites
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to favorites successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Removes a product from favorites
  Future<void> _removeFromFavorites(int productId) async {
    try {
      final favoriteService = ref.read(favoriteServiceProvider);
      await favoriteService.removeFromFavorites(productId.toString());

      // Reload favorites
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from favorites successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing from favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Checks if a product is in favorites
  Future<void> _checkIfInFavorites(int productId) async {
    try {
      final favoriteService = ref.read(favoriteServiceProvider);
      final isInFavorites = await favoriteService.isProductInFavorites(
        productId.toString(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInFavorites
                  ? 'Product is in favorites!'
                  : 'Product is not in favorites',
            ),
            backgroundColor: isInFavorites ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Service Example'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addSampleToFavorites,
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Add Sample'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _checkIfInFavorites(1),
                            icon: const Icon(Icons.search),
                            label: const Text('Check Product 1'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Favorites count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Favorites Count:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_favorites.length}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Favorites list
                  Expanded(
                    child:
                        _favorites.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No favorites yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap "Add Sample" to add a product to favorites',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _favorites.length,
                              itemBuilder: (context, index) {
                                final product = _favorites[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange[100],
                                      child: Text(
                                        '${product.id}',
                                        style: TextStyle(
                                          color: Colors.orange[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      product.productName ?? 'Unknown Product',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Price: ${product.priceSale?.toStringAsFixed(0)}đ',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed:
                                              () => _checkIfInFavorites(
                                                product.id!,
                                              ),
                                          tooltip: 'Check if in favorites',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _removeFromFavorites(
                                                product.id!,
                                              ),
                                          tooltip: 'Remove from favorites',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}

/// Example function that can be called from anywhere in the app
class FavoriteServiceExample {
  static Future<void> addToFavoritesExample({
    required int productId,
    required String productName,
    required int price,
  }) async {
    // This would typically be called with a Provider
    // For demonstration, we'll show the structure

    // 1. Create product model
    final product = ProductModel(
      id: productId,
      productName: productName,
      priceSale: price,
      image: 'product_$productId.jpg',
    );

    // 2. Add to favorites (this would use the actual service)
    // final favoriteService = ref.read(favoriteServiceProvider);
    // await favoriteService.addToFavorites(product);

    print('Would add product $productName to favorites');
  }

  static Future<void> removeFromFavoritesExample(int productId) async {
    // This would typically be called with a Provider
    // final favoriteService = ref.read(favoriteServiceProvider);
    // await favoriteService.removeFromFavorites(productId);

    print('Would remove product $productId from favorites');
  }
}
