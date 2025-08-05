# Firebase Setup for BadminStore App

This document provides instructions for setting up Firebase Authentication and Cloud Firestore in your Flutter app.

## Firebase Configuration

### Project Details

- **Project Name**: badminstoreapp
- **Project ID**: badminstore
- **Project Number**: 927601135515
- **Web API Key**: AIzaSyCS9hvgwz2MwkJmZVPDCOPRr_iBBnLQzwk
- **App ID**: 1:927601135515:android:1b59e033ed23c645991b3e
- **Package Name**: com.badminstoreapp

## Setup Instructions

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `badminstore`
3. Enable the following services:
   - **Authentication**
   - **Cloud Firestore**
   - **Storage**

### 2. Authentication Setup

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable the following providers:
   - **Email/Password**
   - **Google** (optional)
   - **Phone** (optional)

### 3. Firestore Database Setup

1. In Firebase Console, go to **Firestore Database**
2. Create a new database in **production mode**
3. Choose a location closest to your users
4. Set up security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Anyone can read products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Users can read/write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }

    // Anyone can read categories
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 4. Storage Setup

1. In Firebase Console, go to **Storage**
2. Create a new storage bucket
3. Set up security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Product images - anyone can read, authenticated users can write
    match /product_images/{imageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // User avatars - users can read/write their own
    match /user_avatars/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## App Configuration

### Files Created/Modified

1. **`lib/config/firebase_config.dart`** - Firebase configuration constants
2. **`lib/services/firebase_init.dart`** - Firebase initialization
3. **`lib/services/firebase_auth_service.dart`** - Authentication service
4. **`lib/services/firestore_service.dart`** - Firestore database service
5. **`lib/services/firebase_storage_service.dart`** - Storage service
6. **`android/app/google-services.json`** - Android configuration
7. **`pubspec.yaml`** - Updated with Firebase dependencies

### Dependencies Added

```yaml
# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6
firebase_storage: ^11.5.6

# Environment variables
flutter_dotenv: ^5.1.0
```

## Usage Examples

### Authentication

```dart
// Sign in
final authService = ref.read(firebaseAuthServiceProvider);
await authService.signInWithEmailAndPassword(email, password);

// Sign up
await authService.createUserWithEmailAndPassword(email, password);

// Sign out
await authService.signOut();
```

### Firestore

```dart
// Get products
final firestoreService = ref.read(firestoreServiceProvider);
final products = await firestoreService.getProducts();

// Create order
final orderId = await firestoreService.createOrder(orderData);

// Get user profile
final userProfile = await firestoreService.getUserProfile(userId);
```

### Storage

```dart
// Upload product image
final storageService = ref.read(firebaseStorageServiceProvider);
final imageUrl = await storageService.uploadProductImage(imageFile, productId);
```

## Security Considerations

1. **API Keys**: The API key in the configuration is safe to include in client apps as it's restricted by Firebase Security Rules
2. **Authentication**: Always verify user authentication before allowing write operations
3. **Data Validation**: Implement proper data validation on both client and server side
4. **Rate Limiting**: Consider implementing rate limiting for sensitive operations

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Make sure `FirebaseInit.initializeFirebase()` is called in `main()`
2. **Permission denied**: Check Firestore security rules
3. **Network error**: Verify internet connection and Firebase project settings
4. **Build errors**: Run `flutter clean` and `flutter pub get`

### Additional Configuration Needed

If you need additional Firebase services, you may need:

1. **Firebase Messaging** for push notifications
2. **Firebase Analytics** for app analytics
3. **Firebase Crashlytics** for crash reporting
4. **Firebase Performance** for performance monitoring

Let me know if you need help setting up any of these additional services!
