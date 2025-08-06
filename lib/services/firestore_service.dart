import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/firebase_config.dart';
import '../data/model/cartitemmodel.dart';
import '../data/model/productmodel.dart';
import '../data/model/ordermodel.dart';

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

  // Favorites Collection
  CollectionReference<Map<String, dynamic>> get favoritesCollection =>
      _firestore.collection(FirebaseConfig.favoritesCollection);

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

  // Favorite Operations
  /// Adds a product to user's favorites in Firestore (stores only product code)
  Future<void> addToFavorites(String productCode) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // Get or create user's favorites document
      final userFavoritesDoc = favoritesCollection.doc(currentUser.uid);
      final docSnapshot = await userFavoritesDoc.get();

      if (docSnapshot.exists) {
        // User already has a favorites document, add product code to the list
        final data = docSnapshot.data()!;
        List<dynamic> productCodes = List<dynamic>.from(
          data['productCodes'] ?? [],
        );

        if (!productCodes.contains(productCode)) {
          productCodes.add(productCode);
          await userFavoritesDoc.update({
            'productCodes': productCodes,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Create new favorites document for user
        await userFavoritesDoc.set({
          'userId': currentUser.uid,
          'productCodes': [productCode],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to add to favorites: $e';
    }
  }

  /// Removes a product from user's favorites in Firestore
  Future<void> removeFromFavorites(String productCode) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // Get user's favorites document
      final userFavoritesDoc = favoritesCollection.doc(currentUser.uid);
      final docSnapshot = await userFavoritesDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        List<dynamic> productCodes = List<dynamic>.from(
          data['productCodes'] ?? [],
        );

        // Remove the product code
        productCodes.remove(productCode);

        if (productCodes.isEmpty) {
          // If no favorites left, delete the document
          await userFavoritesDoc.delete();
        } else {
          // Update the document with remaining product codes
          await userFavoritesDoc.update({
            'productCodes': productCodes,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw 'Failed to remove from favorites: $e';
    }
  }

  /// Gets all favorite product codes for the current user
  Future<List<String>> getUserFavoriteProductCodes() async {
    try {
      final currentUser = _auth.currentUser;
      print(
        'getUserFavoriteProductCodes: Current user: ${currentUser?.uid}',
      ); // Debug log

      if (currentUser == null) {
        print(
          'getUserFavoriteProductCodes: No user authenticated, returning empty list',
        ); // Debug log
        return [];
      }

      // Get user's favorites document
      final userFavoritesDoc = favoritesCollection.doc(currentUser.uid);
      final docSnapshot = await userFavoritesDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        List<dynamic> productCodes = List<dynamic>.from(
          data['productCodes'] ?? [],
        );

        print(
          'getUserFavoriteProductCodes: Found ${productCodes.length} favorite product codes',
        ); // Debug log
        return productCodes.map((code) => code as String).toList();
      } else {
        print(
          'getUserFavoriteProductCodes: No favorites document found',
        ); // Debug log
        return [];
      }
    } catch (e) {
      print('getUserFavoriteProductCodes: Error: $e'); // Debug log
      throw 'Failed to get user favorite product codes: $e';
    }
  }

  /// Gets all favorite products for the current user (fetches product details by code)
  Future<List<ProductModel>> getUserFavorites() async {
    try {
      final currentUser = _auth.currentUser;
      print('getUserFavorites: Current user: ${currentUser?.uid}'); // Debug log

      if (currentUser == null) {
        print(
          'getUserFavorites: No user authenticated, returning empty list',
        ); // Debug log
        return [];
      }

      // Get favorite product codes
      final productCodes = await getUserFavoriteProductCodes();
      print(
        'getUserFavorites: Found ${productCodes.length} favorite product codes',
      ); // Debug log

      if (productCodes.isEmpty) {
        return [];
      }

      // Fetch product details for each product code
      final products = <ProductModel>[];
      for (final productCode in productCodes) {
        try {
          // Query products collection by code
          final querySnapshot =
              await productsCollection
                  .where('code', isEqualTo: productCode)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            final productData = querySnapshot.docs.first.data();
            products.add(
              ProductModel(
                id: int.tryParse(querySnapshot.docs.first.id) ?? 0,
                productName: productData['productName'],
                image: productData['image'],
                priceSale: productData['priceSale'],
                cost: productData['cost'],
                code: productData['code'],
                brandId: productData['brandId'],
                categoryId: productData['categoryId'],
              ),
            );
            print(
              'getUserFavorites: Loaded product: ${productData['productName']} (Code: $productCode)',
            ); // Debug log
          } else {
            print(
              'getUserFavorites: Product with code $productCode not found',
            ); // Debug log
          }
        } catch (e) {
          print(
            'getUserFavorites: Failed to load product $productCode: $e',
          ); // Debug log
          // Continue loading other products even if one fails
        }
      }

      print(
        'getUserFavorites: Returning ${products.length} favorite products',
      ); // Debug log
      return products;
    } catch (e) {
      print('getUserFavorites: Error: $e'); // Debug log
      throw 'Failed to get user favorites: $e';
    }
  }

  /// Checks if a product is in user's favorites
  Future<bool> isProductInFavorites(String productCode) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Get user's favorites document
      final userFavoritesDoc = favoritesCollection.doc(currentUser.uid);
      final docSnapshot = await userFavoritesDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        List<dynamic> productCodes = List<dynamic>.from(
          data['productCodes'] ?? [],
        );
        return productCodes.contains(productCode);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gets the count of user's favorites
  Future<int> getFavoritesCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 0;
      }

      // Get user's favorites document
      final userFavoritesDoc = favoritesCollection.doc(currentUser.uid);
      final docSnapshot = await userFavoritesDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        List<dynamic> productCodes = List<dynamic>.from(
          data['productCodes'] ?? [],
        );
        return productCodes.length;
      }
      return 0;
    } catch (e) {
      return 0;
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

  // Enhanced Order Operations
  /// Saves a complete order to Firebase Firestore
  ///
  /// [cartItems] - List of cart items containing products and quantities
  /// [totalPrice] - Total price of the order
  /// [shippingInfo] - Shipping information (name, phone, address)
  /// [paymentMethod] - Payment method used
  /// [userId] - Optional user ID (if not provided, uses current user)
  ///
  /// Returns the order ID
  Future<String> saveOrder({
    required List<CartItemModel> cartItems,
    required double totalPrice,
    required Map<String, String> shippingInfo,
    String? paymentMethod,
    String? userId,
    String? orderNotes,
  }) async {
    try {
      // Get current user ID if not provided
      final currentUserId = userId ?? _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw 'User not authenticated';
      }

      // Validate cart items
      if (cartItems.isEmpty) {
        throw 'Cart is empty';
      }

      // Prepare order data
      final orderData = {
        'userId': currentUserId,
        'totalAmount': totalPrice, // Changed from totalPrice to totalAmount
        'subtotal': totalPrice, // Add subtotal field
        'shippingFee': 20000.0, // Add shipping fee
        'taxAmount': 0.0, // Add tax amount
        'items':
            cartItems
                .map(
                  (item) => {
                    'productId': item.product.id.toString(),
                    'productCode': item.product.code,
                    'productName': item.product.productName,
                    'productImage': item.product.image,
                    'unitPrice': item.product.priceSale?.toDouble(),
                    'quantity': item.quantity,
                    'size': item.size,
                    'totalPrice': item.totalPrice.toDouble(),
                  },
                )
                .toList(),
        'receiverName':
            shippingInfo['receiverName'] ?? '', // Flatten shipping info
        'receiverPhone': shippingInfo['receiverPhone'] ?? '',
        'receiverEmail': '', // Add empty email field
        'shippingAddress': shippingInfo['shippingAddress'] ?? '',
        'shippingCity': '', // Add empty city field
        'shippingDistrict': '', // Add empty district field
        'shippingWard': '', // Add empty ward field
        'shippingNote': '', // Add empty note field
        'paymentMethod': paymentMethod ?? 'cash_on_delivery',
        'orderStatus':
            'pending', // pending, processing, shipped, delivered, cancelled
        'paymentStatus': 'pending', // pending, paid, failed
        'deliveryMethod': 'standard', // Add delivery method
        'notes': orderNotes ?? '', // Changed from orderNotes to notes
        'orderCode': OrderModel.generateOrderCode(), // Add order code
        'orderDate': FieldValue.serverTimestamp(), // Add order date
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      final docRef = await ordersCollection.add(orderData);

      // Update product stock if needed (optional)
      await _updateProductStock(cartItems);

      return docRef.id;
    } catch (e) {
      throw 'Failed to save order: $e';
    }
  }

  /// Updates product stock after order placement
  Future<void> _updateProductStock(List<CartItemModel> cartItems) async {
    try {
      final batch = _firestore.batch();

      for (final item in cartItems) {
        if (item.product.id != null) {
          final productRef = productsCollection.doc(item.product.id.toString());
          final productDoc = await productRef.get();

          if (productDoc.exists) {
            final currentStock = productDoc.data()?['stock'] ?? 0;
            final newStock = currentStock - item.quantity;

            if (newStock >= 0) {
              batch.update(productRef, {
                'stock': newStock,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
      }

      await batch.commit();
    } catch (e) {
      // Log error but don't fail the order
      print('Failed to update product stock: $e');
    }
  }

  // ==================== ORDER OPERATIONS ====================

  /// Creates a new order in Firestore
  Future<String> createOrder(OrderModel order) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // Generate order code if not provided
      if (order.orderCode == null) {
        order.orderCode = OrderModel.generateOrderCode();
      }

      // Set user ID and timestamps
      order.userId = currentUser.uid;
      order.orderDate = DateTime.now();
      order.createdAt = DateTime.now();
      order.updatedAt = DateTime.now();

      // Set default status if not provided
      if (order.orderStatus == null) {
        order.orderStatus = 'pending';
      }
      if (order.paymentStatus == null) {
        order.paymentStatus = 'pending';
      }

      // Create the order document
      final docRef = await ordersCollection.add(order.toFirestore());

      print('Order created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      throw 'Failed to create order: $e';
    }
  }

  /// Gets all orders for the current user
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return [];
      }

      print('Getting orders for user: ${currentUser.uid}');

      final querySnapshot =
          await ordersCollection
              .where('userId', isEqualTo: currentUser.uid)
              .get();

      print('Found ${querySnapshot.docs.length} orders in Firestore');

      final orders =
          querySnapshot.docs.map((doc) {
            try {
              print('Processing order document: ${doc.id}');
              print('Document data: ${doc.data()}');
              return OrderModel.fromFirestore(doc);
            } catch (e) {
              print('Error processing order document ${doc.id}: $e');
              print('Document data: ${doc.data()}');
              rethrow;
            }
          }).toList();

      // Sort orders by createdAt in memory (newest first)
      orders.sort((a, b) {
        DateTime dateA = a.createdAt ?? DateTime.now();
        DateTime dateB = b.createdAt ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      print('Successfully processed ${orders.length} orders');
      return orders;
    } catch (e) {
      print('Error getting user orders: $e');
      print('Error stack trace: ${StackTrace.current}');
      throw 'Failed to get user orders: $e';
    }
  }

  /// Gets a specific order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final docSnapshot = await ordersCollection.doc(orderId).get();

      if (docSnapshot.exists) {
        return OrderModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      throw 'Failed to get order: $e';
    }
  }

  /// Updates order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await ordersCollection.doc(orderId).update({
        'orderStatus': newStatus,
        'updatedAt': Timestamp.now(),
      });
      print('Order status updated to: $newStatus');
    } catch (e) {
      print('Error updating order status: $e');
      throw 'Failed to update order status: $e';
    }
  }

  /// Updates payment status
  Future<void> updatePaymentStatus(
    String orderId,
    String newPaymentStatus,
  ) async {
    try {
      await ordersCollection.doc(orderId).update({
        'paymentStatus': newPaymentStatus,
        'updatedAt': Timestamp.now(),
      });
      print('Payment status updated to: $newPaymentStatus');
    } catch (e) {
      print('Error updating payment status: $e');
      throw 'Failed to update payment status: $e';
    }
  }

  /// Cancels an order
  Future<void> cancelOrder(String orderId) async {
    try {
      await ordersCollection.doc(orderId).update({
        'orderStatus': 'cancelled',
        'updatedAt': Timestamp.now(),
      });
      print('Order cancelled successfully');
    } catch (e) {
      print('Error cancelling order: $e');
      throw 'Failed to cancel order: $e';
    }
  }

  /// Gets orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final querySnapshot =
          await ordersCollection
              .where('userId', isEqualTo: currentUser.uid)
              .where('orderStatus', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting orders by status: $e');
      throw 'Failed to get orders by status: $e';
    }
  }

  /// Gets orders within a date range
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final querySnapshot =
          await ordersCollection
              .where('userId', isEqualTo: currentUser.uid)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting orders by date range: $e');
      throw 'Failed to get orders by date range: $e';
    }
  }

  /// Gets order statistics for the current user
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'totalOrders': 0,
          'pendingOrders': 0,
          'completedOrders': 0,
          'cancelledOrders': 0,
          'totalSpent': 0.0,
        };
      }

      final allOrders = await getUserOrders();

      int totalOrders = allOrders.length;
      int pendingOrders =
          allOrders.where((order) => order.orderStatus == 'pending').length;
      int completedOrders =
          allOrders.where((order) => order.orderStatus == 'delivered').length;
      int cancelledOrders =
          allOrders.where((order) => order.orderStatus == 'cancelled').length;

      double totalSpent = allOrders
          .where(
            (order) =>
                order.orderStatus == 'delivered' &&
                order.paymentStatus == 'paid',
          )
          .fold(0.0, (sum, order) => sum + (order.totalAmount ?? 0));

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalSpent': totalSpent,
      };
    } catch (e) {
      print('Error getting order statistics: $e');
      throw 'Failed to get order statistics: $e';
    }
  }

  /// Creates an order from cart items
  Future<String> createOrderFromCart({
    required List<CartItemModel> cartItems,
    required String receiverName,
    required String receiverPhone,
    String? receiverEmail,
    required String shippingAddress,
    String? shippingCity,
    String? shippingDistrict,
    String? shippingWard,
    String? shippingNote,
    required String paymentMethod,
    String? deliveryMethod,
    String? notes,
  }) async {
    try {
      // Calculate totals
      double subtotal = cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      double shippingFee =
          deliveryMethod == 'express'
              ? 50000.0
              : 30000.0; // Example shipping fees
      double taxAmount = subtotal * 0.1; // 10% tax
      double totalAmount = subtotal + shippingFee + taxAmount;

      // Convert cart items to order items
      List<OrderItemModel> orderItems =
          cartItems.map((cartItem) {
            return OrderItemModel(
              productId: cartItem.product.id?.toString(),
              productCode: cartItem.product.code,
              productName: cartItem.product.productName,
              productImage: cartItem.product.image,
              size: cartItem.size,
              quantity: cartItem.quantity,
              unitPrice: cartItem.product.priceSale?.toDouble() ?? 0.0,
              totalPrice: cartItem.totalPrice.toDouble(),
            );
          }).toList();

      // Create order
      final order = OrderModel(
        orderCode: OrderModel.generateOrderCode(),
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        receiverEmail: receiverEmail,
        shippingAddress: shippingAddress,
        shippingCity: shippingCity,
        shippingDistrict: shippingDistrict,
        shippingWard: shippingWard,
        shippingNote: shippingNote,
        subtotal: subtotal,
        shippingFee: shippingFee,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentStatus: 'pending',
        orderStatus: 'pending',
        deliveryMethod: deliveryMethod ?? 'standard',
        items: orderItems,
        notes: notes,
      );

      // Save order to Firestore
      final orderId = await createOrder(order);

      print('Order created from cart with ID: $orderId');
      return orderId;
    } catch (e) {
      print('Error creating order from cart: $e');
      throw 'Failed to create order from cart: $e';
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
