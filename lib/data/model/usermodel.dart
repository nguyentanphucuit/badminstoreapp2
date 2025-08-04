import 'dart:convert';

class UserModel {
  int? id;
  String? username;
  String? email;
  String? fullname;
  String? phonenumber;
  String? birthday;  // Sửa từ 'brithday' thành 'birthday'
  String? password;
  int? role;
  int? status;       // Thêm field status
  String? googleId;  // Thêm field google_id (đổi tên thành googleId theo convention Dart)
  String? loginType; // Thêm field login_type (đổi tên thành loginType theo convention Dart)

  UserModel({
    this.id,
    this.username,
    this.email,
    this.fullname,
    this.phonenumber,
    this.birthday,   // Sửa từ 'brithday' thành 'birthday'
    this.password,
    this.role,
    this.status,     // Thêm vào constructor
    this.googleId,   // Thêm vào constructor
    this.loginType,  // Thêm vào constructor
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    fullname = json['fullname'];
    phonenumber = json['phonenumber'];
    birthday = json['birthday']; 
    password = json['password'];
    role = json['role'];
    status = json['status'];         // Thêm mapping cho status
    googleId = json['google_id'];    // Thêm mapping cho google_id
    loginType = json['login_type'];  // Thêm mapping cho login_type
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['fullname'] = fullname;
    data['phonenumber'] = phonenumber;
    data['birthday'] = birthday;   
    data['password'] = password;
    data['role'] = role;
    data['status'] = status;           // Thêm mapping cho status
    data['google_id'] = googleId;      // Thêm mapping cho google_id
    data['login_type'] = loginType;    // Thêm mapping cho login_type
    return data;
  }
}