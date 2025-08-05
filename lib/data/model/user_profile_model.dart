import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? photoURL;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.photoURL,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      photoURL: map['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'photoURL': photoURL,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? photoURL,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}
