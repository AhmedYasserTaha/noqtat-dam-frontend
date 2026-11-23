import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.bloodType,
  });
  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: json['id'] as int,
    name: json['name'] as String,
    phone: json['phone'] as String,
    bloodType: json['bloodType'] as String,
  );
}
