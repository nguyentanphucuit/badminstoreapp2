import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';
import 'login_register_forget/login_with_firebase.dart';
import 'mainpage.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          print('AuthWrapper: User signed in, showing MainPage'); // Debug log
          // User is signed in, show main page
          return const MainPage();
        } else {
          print(
            'AuthWrapper: User not signed in, showing LoginScreen',
          ); // Debug log
          // User is not signed in, show login page
          return const LoginWithFirebaseScreen();
        }
      },
      loading: () {
        print('AuthWrapper: Loading auth state...'); // Debug log
        // Show loading screen while checking auth state
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB382), Color(0xFFFF8C42)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        print('AuthWrapper: Auth error: $error'); // Debug log
        // Show error screen or fallback to login
        return const LoginWithFirebaseScreen();
      },
    );
  }
}
