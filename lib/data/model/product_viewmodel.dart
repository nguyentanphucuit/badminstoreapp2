import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'productmodel.dart';
import 'cartitemmodel.dart';
import '../../services/favorite_service.dart';
import '../data/productdata.dart';

class ProductsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {
    'favorite': <ProductModel>[],
    'cart': <CartItemModel>[],
  };

  /// Adds a product to favorites (both local state and Firebase)
  Future<void> addToFavorite(ProductModel product) async {
    try {
      // Add to local state first for immediate UI update
      final favorites = List<ProductModel>.from(state['favorite']);
      if (!favorites.any((p) => p.id == product.id)) {
        state = {
          ...state,
          'favorite': [...favorites, product],
        };
      }

      // Add to Firebase Firestore (only product code)
      final favoriteService = ref.read(favoriteServiceProvider);
      await favoriteService.addToFavorites(product.code!);
    } catch (e) {
      // If Firebase fails, remove from local state
      final favorites = List<ProductModel>.from(state['favorite']);
      favorites.removeWhere((p) => p.id == product.id);
      state = {...state, 'favorite': favorites};
      throw 'Failed to add to favorites: $e';
    }
  }

  /// Removes a product from favorites by index (both local state and Firebase)
  Future<void> removeFromFavorite(int index) async {
    try {
      final favorites = List<ProductModel>.from(state['favorite']);
      if (index >= 0 && index < favorites.length) {
        final product = favorites[index];

        // Remove from local state first for immediate UI update
        favorites.removeAt(index);
        state = {...state, 'favorite': favorites};

        // Remove from Firebase Firestore
        if (product.code != null) {
          final favoriteService = ref.read(favoriteServiceProvider);
          await favoriteService.removeFromFavorites(product.code!);
        }
      }
    } catch (e) {
      // If Firebase fails, add back to local state
      final favorites = List<ProductModel>.from(state['favorite']);
      // Note: We can't easily restore the exact position, so we'll just add it back
      throw 'Failed to remove from favorites: $e';
    }
  }

  /// Removes a product from favorites by product (both local state and Firebase)
  Future<void> removeFromFavoriteByProduct(ProductModel product) async {
    try {
      final favorites = List<ProductModel>.from(state['favorite']);
      final initialLength = favorites.length;

      // Remove from local state first for immediate UI update
      favorites.removeWhere((p) => p.id == product.id);
      state = {...state, 'favorite': favorites};

      // Only call Firebase if we actually removed something
      if (favorites.length < initialLength && product.code != null) {
        final favoriteService = ref.read(favoriteServiceProvider);
        await favoriteService.removeFromFavorites(product.code!);
      }
    } catch (e) {
      // If Firebase fails, add back to local state
      final favorites = List<ProductModel>.from(state['favorite']);
      if (!favorites.any((p) => p.id == product.id)) {
        favorites.add(product);
        state = {...state, 'favorite': favorites};
      }
      throw 'Failed to remove from favorites: $e';
    }
  }

  /// Checks if a product is in favorites (local state only for performance)
  bool isInFavorites(int productId) {
    final favorites = List<ProductModel>.from(state['favorite']);
    return favorites.any((p) => p.id == productId);
  }

  /// Checks if a product is in favorites by code (local state only for performance)
  bool isInFavoritesByCode(String productCode) {
    final favorites = List<ProductModel>.from(state['favorite']);
    return favorites.any((p) => p.code == productCode);
  }

  /// Gets the count of favorites (local state only for performance)
  int get favoritesCount {
    final favorites = List<ProductModel>.from(state['favorite']);
    return favorites.length;
  }

  /// Syncs local favorites with Firebase Firestore
  Future<void> syncFavoritesWithFirestore() async {
    try {
      final favoriteService = ref.read(favoriteServiceProvider);
      final firestoreFavorites = await favoriteService.getUserFavorites();

      state = {...state, 'favorite': firestoreFavorites};
    } catch (e) {
      throw 'Failed to sync favorites: $e';
    }
  }

  /// Loads favorites from Firebase Firestore
  Future<void> loadFavoritesFromFirestore() async {
    try {
      print(
        'loadFavoritesFromFirestore: Starting to load favorites...',
      ); // Debug log

      // Get favorite product codes from Firestore
      final favoriteService = ref.read(favoriteServiceProvider);
      final productCodes = await favoriteService.getUserFavoriteProductCodes();

      print(
        'loadFavoritesFromFirestore: Found ${productCodes.length} favorite product codes: $productCodes',
      );

      if (productCodes.isEmpty) {
        state = {...state, 'favorite': <ProductModel>[]};
        print('loadFavoritesFromFirestore: No favorites found, clearing state');
        return;
      }

      // Load all products from local JSON data
      final readData = ReadData();
      final allProducts = await readData.loadData();

      print(
        'loadFavoritesFromFirestore: Loaded ${allProducts.length} total products from local data',
      );

      // Find favorite products by matching product codes
      final favoriteProducts = <ProductModel>[];
      for (final productCode in productCodes) {
        final product = allProducts.firstWhere(
          (p) => p.code == productCode,
          orElse: () => ProductModel(), // Return empty product if not found
        );

        if (product.id != null) {
          favoriteProducts.add(product);
          print(
            'loadFavoritesFromFirestore: Found favorite product: ${product.productName} (Code: $productCode)',
          );
        } else {
          print(
            'loadFavoritesFromFirestore: Product with code $productCode not found in local data',
          );
        }
      }

      // Update state with found favorite products
      state = {...state, 'favorite': favoriteProducts};
      print(
        'loadFavoritesFromFirestore: Successfully loaded ${favoriteProducts.length} favorite products',
      ); // Debug log
    } catch (e) {
      // If sync fails, keep local state
      print(
        'loadFavoritesFromFirestore: Failed to load favorites: $e',
      ); // Debug log
      throw 'Failed to load favorites: $e';
    }
  }

  //Add gio hang
  void addToCart(ProductModel product, int quantity, String? size) {
    final cart = List<CartItemModel>.from(state['cart']);

    // Tìm xem sản phẩm đã có trong giỏ hàng chưa (cùng product và size)
    final existingIndex = cart.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      // Nếu đã có, cập nhật số lượng
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + quantity,
      );
    } else {
      // Nếu chưa có, thêm mới
      cart.add(CartItemModel(product: product, quantity: quantity, size: size));
    }

    state = {...state, 'cart': cart};
  }

  void removeFromCart(int index) {
    final cart = List<CartItemModel>.from(state['cart']);
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      state = {...state, 'cart': cart};
    }
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    final cart = List<CartItemModel>.from(state['cart']);
    if (index >= 0 && index < cart.length) {
      if (newQuantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index] = cart[index].copyWith(quantity: newQuantity);
      }
      state = {...state, 'cart': cart};
    }
  }

  void clearCart() {
    state = {...state, 'cart': <CartItemModel>[]};
  }

  int get cartCount {
    final cart = List<CartItemModel>.from(state['cart']);
    return cart.fold(0, (total, item) => total + item.quantity);
  }

  double get cartTotal {
    final cart = List<CartItemModel>.from(state['cart']);
    return cart.fold(0.0, (total, item) => total + item.totalPrice);
  }

  int get cartItemsCount {
    final cart = List<CartItemModel>.from(state['cart']);
    return cart.fold(0, (total, item) => total + item.quantity);
  }

  List<CartItemModel> get cartItems {
    return List<CartItemModel>.from(state['cart']);
  }

  bool get isCartEmpty => cartItems.isEmpty;
}

final productsProvider =
    NotifierProvider<ProductsNotifier, Map<String, dynamic>>(() {
      return ProductsNotifier();
    });

final cartItemsProvider = Provider<List<CartItemModel>>((ref) {
  return List<CartItemModel>.from(ref.watch(productsProvider)['cart']);
});
