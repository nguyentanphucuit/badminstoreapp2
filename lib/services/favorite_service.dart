import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/productmodel.dart';
import 'firestore_service.dart';

class FavoriteService {
  final FirestoreService _firestoreService;

  FavoriteService(this._firestoreService);

  /// Adds a product to favorites (stores only product code)
  Future<void> addToFavorites(String productCode) async {
    return await _firestoreService.addToFavorites(productCode);
  }

  /// Removes a product from favorites
  Future<void> removeFromFavorites(String productCode) async {
    return await _firestoreService.removeFromFavorites(productCode);
  }

  /// Gets all favorite products for the current user
  Future<List<ProductModel>> getUserFavorites() async {
    return await _firestoreService.getUserFavorites();
  }

  /// Gets all favorite product codes for the current user
  Future<List<String>> getUserFavoriteProductCodes() async {
    return await _firestoreService.getUserFavoriteProductCodes();
  }

  /// Checks if a product is in favorites
  Future<bool> isProductInFavorites(String productCode) async {
    return await _firestoreService.isProductInFavorites(productCode);
  }

  /// Gets the count of user's favorites
  Future<int> getFavoritesCount() async {
    return await _firestoreService.getFavoritesCount();
  }

  /// Syncs local favorites with Firebase Firestore
  Future<List<ProductModel>> syncFavoritesWithFirestore() async {
    return await getUserFavorites();
  }
}

// Provider for Favorite Service
final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return FavoriteService(firestoreService);
});

// Provider for user favorites from Firestore
final userFavoritesProvider = FutureProvider<List<ProductModel>>((ref) async {
  final favoriteService = ref.watch(favoriteServiceProvider);
  return await favoriteService.getUserFavorites();
});

// Provider for checking if a product is in favorites
final isProductInFavoritesProvider = FutureProvider.family<bool, String>((
  ref,
  productCode,
) async {
  final favoriteService = ref.watch(favoriteServiceProvider);
  return await favoriteService.isProductInFavorites(productCode);
});

// Provider for favorites count
final favoritesCountProvider = FutureProvider<int>((ref) async {
  final favoriteService = ref.watch(favoriteServiceProvider);
  return await favoriteService.getFavoritesCount();
});
