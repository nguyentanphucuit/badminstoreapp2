import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firebase_init.dart';
import 'config/app_config.dart';
import 'page/start.dart';
import 'page/auth_wrapper.dart';
import 'page/login_register_forget/login_with_firebase.dart';
import 'page/login_register_forget/register_with_firebase.dart';
import 'page/login_register_forget/forget.dart';
import 'page/login_register_forget/passcode.dart';
import 'page/login_register_forget/resetpass.dart';
import 'page/shipping/shippingaddress.dart';
import 'page/shipping/payment.dart';
import 'page/cart/productcart.dart';
import 'page/product/productbody.dart';
import 'page/product/productlist.dart';
import 'page/mainpage.dart';
import 'page/home/mainhome.dart';
import 'page/search/search.dart';
import 'page/order/mainorder.dart';
import 'page/personal/mainpersonal.dart';
import 'page/personal/about.dart';
import 'page/personal/support.dart';
import 'page/personal/changepassword.dart';
import 'page/shipping/orderconfirm.dart';
import 'page/intro.dart';
import 'page/shipping/thank.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Main: Starting app initialization'); // Debug log

  // Initialize Firebase
  try {
    await FirebaseInit.initializeFirebase();
    print('Main: Firebase initialized successfully'); // Debug log
  } catch (e) {
    print('Main: Firebase initialization failed: $e'); // Debug log
    rethrow;
  }

  print('Main: Running app'); // Debug log
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartScreen(),
    );
  }
}
