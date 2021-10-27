import 'dart:convert';

class UserModel {
  String userId;
  UserModel({
    required this.userId,
  });
}

class UserInfor {
  String email;
  String name;
  String avatar;
  String phone;
  UserInfor({
    required this.email,
    required this.name,
    required this.avatar,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatar': avatar,
      'phone': phone,
    };
  }

  factory UserInfor.fromMap(Map<String, dynamic> map) {
    return UserInfor(
      email: map['email'],
      name: map['name'],
      avatar: map['avatar'],
      phone: map['phone'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfor.fromJson(String source) =>
      UserInfor.fromMap(json.decode(source));
}
