import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.watchProfile, this.saveProfile)
    : super(const ProfileState());
  final WatchProfile watchProfile;
  final SaveProfile saveProfile;
  StreamSubscription<Object?>? _subscription;
  int _generation = 0;
  Future<void> watch(String? uid) async {
    final generation = ++_generation;
    emit(
      ProfileState(
        status: uid == null ? ProfileStatus.initial : ProfileStatus.loading,
      ),
    );
    await _subscription?.cancel();
    if (generation != _generation || isClosed || uid == null) return;
    _subscription = watchProfile(uid).listen((result) {
      if (generation != _generation || isClosed) return;
      result.fold(
        (f) => emit(ProfileState(status: ProfileStatus.failure, failure: f)),
        (p) => emit(ProfileState(status: ProfileStatus.loaded, profile: p)),
      );
    });
  }

  Future<void> save(UserProfile profile) async {
    final result = await saveProfile(profile);
    if (isClosed) return;
    result.fold(
      (f) => emit(ProfileState(status: ProfileStatus.failure, failure: f)),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}
