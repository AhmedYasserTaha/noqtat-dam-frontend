import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.uid, super.phone});
  factory AuthUserModel.fromMap(Map<String, dynamic> map) =>
      AuthUserModel(uid: map['uid'] as String, phone: map['phone'] as String?);
  Map<String, dynamic> toMap() => {'uid': uid, 'phone': phone};
}
