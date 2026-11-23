import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.bloodType,
  });
  final int id;
  final String name, phone, bloodType;
  @override
  List<Object?> get props => [id, name, phone, bloodType];
}

class RegisterData extends Equatable {
  const RegisterData({
    required this.name,
    required this.phone,
    required this.password,
    required this.bloodType,
    this.governorateId,
    this.districtId,
  });
  final String name, phone, password, bloodType;
  final String? governorateId, districtId;
  @override
  List<Object?> get props => [
    name,
    phone,
    password,
    bloodType,
    governorateId,
    districtId,
  ];
}
