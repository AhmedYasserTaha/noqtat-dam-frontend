import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.failure,
  });
  final ProfileStatus status;
  final UserProfile? profile;
  final Failure? failure;
  bool get isComplete =>
      profile != null &&
      profile!.name.trim().isNotEmpty &&
      profile!.bloodType.isNotEmpty &&
      profile!.governorate.trim().isNotEmpty;
  @override
  List<Object?> get props => [status, profile, failure];
}
