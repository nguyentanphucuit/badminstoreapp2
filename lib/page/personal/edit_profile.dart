import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _userProfileData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final userProfileData = await firestoreService.getUserProfile(user.uid);

        if (userProfileData != null) {
          setState(() {
            _userProfileData = userProfileData;
            _displayNameController.text =
                userProfileData['displayName']?.toString() ?? '';
            _phoneNumberController.text =
                userProfileData['phoneNumber']?.toString() ?? '';
            _addressController.text =
                userProfileData['address']?.toString() ?? '';
          });
        } else {
          // If no Firestore profile, use Firebase Auth data
          setState(() {
            _displayNameController.text = user.displayName ?? '';
            _phoneNumberController.text = '';
            _addressController.text = '';
          });
        }
      } catch (e) {
        print('Error loading user profile: $e');
        // Fallback to Firebase Auth data
        setState(() {
          _displayNameController.text = user.displayName ?? '';
          _phoneNumberController.text = '';
          _addressController.text = '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        _showSnackBar('Không tìm thấy thông tin người dùng', isSuccess: false);
        return;
      }

      final firestoreService = ref.read(firestoreServiceProvider);

      // Update Firestore profile
      await firestoreService.updateUserProfile(user.uid, {
        'displayName': _displayNameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'address': _addressController.text.trim(),
      });

      // Update Firebase Auth display name
      await ref
          .read(authProvider.notifier)
          .updateUserProfile(displayName: _displayNameController.text.trim());

      _showSnackBar('Cập nhật thông tin thành công!', isSuccess: true);

      // Navigate back after successful update
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      // _showSnackBar('Lỗi cập nhật: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: isSuccess ? 2 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sửa thông tin cá nhân',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD2691E),
                        shape: BoxShape.circle,
                      ),
                      child:
                          _userProfileData?['displayName'] != null &&
                                  _userProfileData!['displayName']
                                      .toString()
                                      .isNotEmpty
                              ? Center(
                                child: Text(
                                  _getInitials(
                                    _userProfileData!['displayName'].toString(),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thông tin cá nhân',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cập nhật thông tin cá nhân của bạn',
                      style: TextStyle(fontSize: 14, color: Color(0xFF8B4513)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Display Name Field
              const Text(
                'Họ và tên',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _displayNameController,
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập họ và tên',
                    hintStyle: TextStyle(
                      color: Color(0xFF8B4513).withOpacity(0.7),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF8B4513),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Phone Number Field
              const Text(
                'Số điện thoại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _phoneNumberController,
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập số điện thoại',
                    hintStyle: TextStyle(
                      color: Color(0xFF8B4513).withOpacity(0.7),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF8B4513),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Address Field
              const Text(
                'Địa chỉ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _addressController,
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ',
                    hintStyle: TextStyle(
                      color: Color(0xFF8B4513).withOpacity(0.7),
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8B4513),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2691E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Cập nhật',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return 'U';
  }
}
