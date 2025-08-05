import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/firebase_config.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload product image
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child(
        '${FirebaseConfig.productImagesPath}/$productId.jpg',
      );

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload product image: $e';
    }
  }

  // Upload user avatar
  Future<String> uploadUserAvatar(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child(
        '${FirebaseConfig.userAvatarsPath}/$userId.jpg',
      );

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload user avatar: $e';
    }
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  // Get file download URL
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL: $e';
    }
  }
}

// Provider for Firebase Storage Service
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});
