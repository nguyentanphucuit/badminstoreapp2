import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/firebase_config.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Users Collection
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection(FirebaseConfig.usersCollection);

  // Products Collection
  CollectionReference<Map<String, dynamic>> get productsCollection =>
      _firestore.collection(FirebaseConfig.productsCollection);

  // Orders Collection
  CollectionReference<Map<String, dynamic>> get ordersCollection =>
      _firestore.collection(FirebaseConfig.ordersCollection);

  // Categories Collection
  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection(FirebaseConfig.categoriesCollection);

  // User Operations
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName ?? '',
        'phoneNumber': phoneNumber ?? '',
        'address': address ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      return doc.data();
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await usersCollection.doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // Product Operations
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await productsCollection.add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    int? limit,
  }) async {
    try {
      Query query = productsCollection.where('isActive', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final Map<String, dynamic> result = {'id': doc.id};
        if (data != null) {
          result.addAll(data as Map<String, dynamic>);
        }
        return result;
      }).toList();
    } catch (e) {
      throw 'Failed to get products: $e';
    }
  }

  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw 'Failed to get product: $e';
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await productsCollection.doc(productId).update(data);
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  // Order Operations
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final docRef = await ordersCollection.add({
        ...orderData,
        'userId': _auth.currentUser?.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final querySnapshot =
          await ordersCollection
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw 'Failed to get user orders: $e';
    }
  }

  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final doc = await ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw 'Failed to get order: $e';
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  // Category Operations
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final querySnapshot =
          await categoriesCollection
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw 'Failed to get categories: $e';
    }
  }

  // Search Operations
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation - you might want to use Algolia or similar
      final querySnapshot =
          await productsCollection.where('isActive', isEqualTo: true).get();

      final products =
          querySnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();

      return products.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final description =
            product['description']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw 'Failed to search products: $e';
    }
  }
}

// Provider for Firestore Service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
