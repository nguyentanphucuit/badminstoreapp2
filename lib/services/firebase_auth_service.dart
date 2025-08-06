import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuthService() {
    // Firebase Auth automatically persists sessions on mobile platforms
    // No need to call setPersistence() on mobile
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is email verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Check if user session is valid and refresh if needed
  Future<bool> isUserSessionValid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Refresh the user's token to ensure it's still valid
      await user.getIdToken(true);
      return true;
    } catch (e) {
      print('Session validation failed: $e');
      return false;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Re-authenticate user with password
  Future<void> reauthenticateWithPassword(String email, String password) async {
    try {
      print('FirebaseAuthService: Creating credential for email: $email');
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No current user found');
      }

      print('FirebaseAuthService: Re-authenticating user: ${currentUser.uid}');
      await currentUser.reauthenticateWithCredential(credential);
      print('FirebaseAuthService: Re-authentication successful');
    } catch (e) {
      print('FirebaseAuthService: Re-authentication error: $e');
      throw _handleAuthError(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user email
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user password
  Future<void> updateUserPassword(String newPassword) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No current user found');
      }

      print(
        'FirebaseAuthService: Updating password for user: ${currentUser.uid}',
      );
      await currentUser.updatePassword(newPassword);
      print('FirebaseAuthService: Password update successful');
    } catch (e) {
      print('FirebaseAuthService: Password update error: $e');
      throw _handleAuthError(e);
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    print('FirebaseAuthService: Handling error: $error');
    print('FirebaseAuthService: Error type: ${error.runtimeType}');

    if (error is FirebaseAuthException) {
      print('FirebaseAuthService: FirebaseAuthException code: ${error.code}');
      print(
        'FirebaseAuthService: FirebaseAuthException message: ${error.message}',
      );

      switch (error.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này. Vui lòng kiểm tra lại email hoặc đăng ký tài khoản mới.';
        case 'wrong-password':
          return 'Mật khẩu không đúng. Vui lòng thử lại.';
        case 'email-already-in-use':
          return 'Email này đã được sử dụng bởi tài khoản khác.';
        case 'weak-password':
          return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        case 'invalid-email':
          return 'Email không hợp lệ. Vui lòng kiểm tra lại.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'too-many-requests':
          return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
        case 'operation-not-allowed':
          return 'Thao tác này không được phép.';
        case 'requires-recent-login':
          return 'Thao tác này yêu cầu đăng nhập gần đây.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        default:
          return 'Lỗi xác thực: ${error.message}';
      }
    }

    // Handle other types of errors
    if (error.toString().contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'An unexpected error occurred: ${error.toString()}';
  }
}

// Provider for Firebase Auth Service
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});
