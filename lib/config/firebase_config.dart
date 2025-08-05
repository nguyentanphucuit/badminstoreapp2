import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static const String projectId = 'badminstore';
  static const String projectNumber = '927601135515';
  static const String webApiKey = 'AIzaSyCS9hvgwz2MwkJmZVPDCOPRr_iBBnLQzwk';
  static const String appId = '1:927601135515:android:1b59e033ed23c645991b3e';
  static const String appNickname = 'BadminStoreApp';
  static const String packageName = 'com.badminstoreapp';

  // Firebase Auth settings
  static const bool enableEmailAuth = true;
  static const bool enableGoogleAuth = true;
  static const bool enablePhoneAuth = false;

  // Firestore settings
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';

  // Storage settings
  static const String productImagesPath = 'product_images';
  static const String userAvatarsPath = 'user_avatars';

  static Future<void> loadEnvironmentVariables() async {
    await dotenv.load(fileName: ".env");
  }
}
