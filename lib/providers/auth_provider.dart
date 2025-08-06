import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthNotifier(this._authService, this._firestoreService)
    : super(const AsyncValue.loading()) {
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    try {
      // Check initial user state
      final initialUser = _authService.currentUser;
      print(
        'AuthNotifier: Initial user state - User: ${initialUser?.uid}',
      ); // Debug log
      print(
        'AuthNotifier: Email verified: ${_authService.isEmailVerified}',
      ); // Debug log

      if (initialUser != null) {
        // Validate the session
        final isSessionValid = await _authService.isUserSessionValid();
        if (isSessionValid) {
          print('AuthNotifier: Setting initial user state'); // Debug log
          state = AsyncValue.data(initialUser);
        } else {
          print('AuthNotifier: Session invalid, signing out'); // Debug log
          await _authService.signOut();
          state = const AsyncValue.data(null);
        }
      } else {
        state = const AsyncValue.data(null);
      }

      // Listen to auth state changes
      _authService.authStateChanges.listen(
        (user) {
          print(
            'AuthNotifier: Auth state changed - User: ${user?.uid}',
          ); // Debug log
          state = AsyncValue.data(user);
        },
        onError: (error) {
          print('AuthNotifier: Auth state error: $error'); // Debug log
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e) {
      print('AuthNotifier: Initialization error: $e'); // Debug log
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      print('AuthProvider: Starting sign in for email: $email');
      await _authService.signInWithEmailAndPassword(email, password);
      print('AuthProvider: Sign in successful');

      // Update last login time in Firestore
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        try {
          await _firestoreService.updateLastLogin(currentUser.uid);
          print('✅ Last login time updated in Firestore');
        } catch (e) {
          print('❌ Failed to update last login time: $e');
          // Don't fail sign in if this fails
        }
      }

      // Don't set error state here, let the auth state listener handle it
    } catch (e) {
      print('AuthProvider: Sign in error: $e');

      // Check if user was actually logged in despite the error
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // User was logged in successfully, don't rethrow
        print(
          'AuthProvider: User logged in successfully despite error: ${currentUser.uid}',
        );
        return;
      }

      // Reset loading state for failed login
      state = const AsyncValue.data(null);
      print('AuthProvider: Reset loading state for failed login');

      // ALWAYS rethrow ALL errors so UI can show them
      print('AuthProvider: Rethrowing ALL errors to UI: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      state = const AsyncValue.loading();
      print('Starting registration for email: $email'); // Debug log

      // Create user account
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      print(
        'Firebase Auth user created: ${userCredential.user?.uid}',
      ); // Debug log

      // Create user profile in Firestore after successful Firebase Auth registration
      if (userCredential.user != null) {
        try {
          print('🔍 DEBUG: About to create Firestore profile');
          print('🔍 DEBUG: User UID: ${userCredential.user!.uid}');
          print('🔍 DEBUG: User Email: $email');
          print('🔍 DEBUG: FirestoreService instance: $_firestoreService');

          await _firestoreService.createUserProfile(
            uid: userCredential.user!.uid,
            email: email,
            displayName: displayName,
            phoneNumber: phoneNumber,
            address: address,
          );
          print('✅ Firestore profile created successfully for user: $email');
        } catch (firestoreError) {
          print('❌ Firestore profile creation failed: $firestoreError');
          print('❌ Firestore error type: ${firestoreError.runtimeType}');
          print('❌ Firestore error details: $firestoreError');
          // Don't fail registration if Firestore is not available
          // User can still use the app, profile can be created later
        }

        // User is automatically signed in after successful registration
        print(
          '✅ User automatically signed in after registration: ${userCredential.user!.uid}',
        );
      }

      print('Registration completed successfully'); // Debug log
      // Don't set error state for successful registration
    } catch (e) {
      print('Registration error: $e'); // Debug log

      // Check if user was actually created successfully
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        print(
          'User was created successfully despite error: ${currentUser.uid}',
        ); // Debug log
        // Don't rethrow if user was created successfully
        return;
      }

      // Only rethrow if user creation actually failed
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  // Check if current user is email verified
  bool get isEmailVerified => _authService.isEmailVerified;

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update user email
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await _authService.updateUserEmail(newEmail);
    } catch (e) {
      rethrow;
    }
  }

  // Re-authenticate user with password
  Future<void> reauthenticateWithPassword(String email, String password) async {
    try {
      print('AuthProvider: Re-authenticating user with email: $email');
      await _authService.reauthenticateWithPassword(email, password);
      print('AuthProvider: Re-authentication successful');
    } catch (e) {
      print('AuthProvider: Re-authentication failed: $e');
      rethrow;
    }
  }

  // Update user password
  Future<void> updateUserPassword(String newPassword) async {
    try {
      print('AuthProvider: Updating user password');
      await _authService.updateUserPassword(newPassword);
      print('AuthProvider: Password update successful');
    } catch (e) {
      print('AuthProvider: Password update failed: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      await _authService.deleteUserAccount();
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AuthNotifier(authService, firestoreService);
});

// Provider for current user (simplified)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for authentication state
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
