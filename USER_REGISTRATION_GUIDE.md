# User Registration Guide with Firebase

This guide explains how to register new user accounts in your BadminStore app using Firebase Authentication and Firestore.

## 🚀 How to Register an Account

### 1. Using the Firebase Registration Page

The app now includes a complete Firebase-integrated registration page at:

```
lib/page/login_register_forget/register_with_firebase.dart
```

**Features:**

- ✅ Email validation
- ✅ Password strength validation
- ✅ Password confirmation
- ✅ Required field validation
- ✅ Terms and conditions agreement
- ✅ Loading states
- ✅ Error handling
- ✅ Success feedback

### 2. Registration Flow

1. **User fills out the registration form:**

   - Full Name (required)
   - Email (required, validated)
   - Phone Number (required)
   - Address (required)
   - Password (minimum 6 characters)
   - Confirm Password (must match)

2. **Form validation:**

   - All required fields must be filled
   - Email format must be valid
   - Password must be at least 6 characters
   - Passwords must match
   - Terms must be agreed to

3. **Firebase account creation:**

   - Creates Firebase Auth account
   - Creates user profile in Firestore
   - Sends email verification (if enabled)

4. **Success handling:**
   - Shows success message
   - Redirects to login page
   - User can now sign in

## 📱 How to Use the Registration

### From Login Page

1. Open the login page
2. Click "Đăng ký" (Register) link at the bottom
3. Fill out the registration form
4. Click "Đăng ký" button

### Direct Navigation

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const RegisterWithFirebaseScreen(),
  ),
);
```

## 🔧 Code Examples

### Basic Registration

```dart
// In any widget with ConsumerWidget
final authNotifier = ref.read(authProvider.notifier);

await authNotifier.signUpWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
  phoneNumber: '+1234567890',
  address: '123 Main St, City',
);
```

### Registration with Validation

```dart
Future<void> registerUser() async {
  try {
    await ref.read(authProvider.notifier).signUpWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
      displayName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      address: addressController.text.trim(),
    );

    // Success - user is registered
    showSuccessMessage('Registration successful!');

  } catch (e) {
    // Handle error
    showErrorMessage('Registration failed: ${e.toString()}');
  }
}
```

## 🗄️ Data Storage

### Firebase Auth

- User account created with email/password
- Unique UID generated automatically
- Email verification status tracked

### Firestore Database

User profile stored in `users` collection:

```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "phoneNumber": "+1234567890",
  "address": "123 Main St, City",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "isActive": true,
  "photoURL": null
}
```

## ✅ Validation Rules

### Email Validation

- Must be a valid email format
- Cannot be empty
- Must be unique (Firebase handles this)

### Password Validation

- Minimum 6 characters
- Cannot be empty
- Confirmation must match

### Required Fields

- Full Name
- Email
- Phone Number
- Address
- Password
- Terms agreement

## 🛡️ Security Features

### Firebase Security Rules

```javascript
// Firestore rules for users collection
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

### Data Protection

- Passwords are hashed by Firebase Auth
- User data is protected by Firestore security rules
- Only authenticated users can access their own data

## 🔄 Registration States

### Loading State

- Button shows loading spinner
- Form is disabled
- User cannot submit multiple times

### Success State

- Success message displayed
- Redirect to login page
- User can sign in immediately

### Error State

- Error message displayed
- Form remains enabled
- User can try again

## 📧 Email Verification

### Automatic Email Verification

Firebase automatically sends verification emails when:

- Email verification is enabled in Firebase Console
- New user registers with email/password

### Manual Email Verification

```dart
// Send verification email
await FirebaseAuth.instance.currentUser?.sendEmailVerification();

// Check if email is verified
bool isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
```

## 🧪 Testing Registration

### Test Cases

1. **Valid Registration:**

   - Fill all fields correctly
   - Should create account successfully

2. **Invalid Email:**

   - Enter invalid email format
   - Should show validation error

3. **Weak Password:**

   - Enter password less than 6 characters
   - Should show validation error

4. **Password Mismatch:**

   - Enter different passwords
   - Should show validation error

5. **Missing Fields:**

   - Leave required fields empty
   - Should show validation errors

6. **Terms Not Agreed:**
   - Try to register without checking terms
   - Should show error message

## 🚨 Common Issues

### "Email already in use"

- User already has an account
- Direct them to login page

### "Weak password"

- Password must be at least 6 characters
- Suggest stronger password

### "Invalid email"

- Check email format
- Ensure no extra spaces

### Network errors

- Check internet connection
- Try again later

## 📱 Integration with Existing App

### Replace Current Registration

To use Firebase registration instead of your current system:

1. **Update navigation:**

```dart
// Replace this:
Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));

// With this:
Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterWithFirebaseScreen()));
```

2. **Update imports:**

```dart
import 'register_with_firebase.dart';
```

3. **Test the flow:**

- Registration → Login → Main App

## 🎯 Next Steps

After successful registration:

1. **User can sign in** with their email and password
2. **Profile data is available** in Firestore
3. **User can update profile** using the auth provider
4. **User can reset password** if needed

## 📞 Support

If you encounter issues with registration:

1. Check Firebase Console for errors
2. Verify Firebase configuration
3. Check network connection
4. Review validation messages
5. Test with different email addresses

The registration system is now fully integrated with Firebase and ready to use!
