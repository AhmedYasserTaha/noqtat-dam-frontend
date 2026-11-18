import 'package:equatable/equatable.dart';

class Pledge extends Equatable {
  const Pledge({
    required this.donorId,
    required this.donorName,
    required this.status,
    required this.createdAt,
  });
  final String donorId;
  final String donorName;
  final String status;
  final DateTime createdAt;
  @override
  List<Object?> get props => [donorId, donorName, status, createdAt];
}
