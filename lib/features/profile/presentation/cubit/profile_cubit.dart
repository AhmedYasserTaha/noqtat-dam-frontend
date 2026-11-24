import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_usecases.dart';

enum ProfileStatus { loading, ready, failure, deleted }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.donations = const [],
    this.failure,
    this.actionFailure,
  });
  final ProfileStatus status;
  final UserProfile? profile;
  final List<DonationRecord> donations;
  final Failure? failure, actionFailure;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<DonationRecord>? donations,
    Failure? failure,
    Failure? actionFailure,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    donations: donations ?? this.donations,
    failure: failure,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    profile,
    donations,
    failure,
    actionFailure,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._get, this._update, this._history, this._delete)
    : super(const ProfileState());
  final GetProfile _get;
  final UpdateProfile _update;
  final GetDonationHistory _history;
  final DeleteAccount _delete;

  /// The session restore response already contains the full profile.
  void seed(UserProfile profile) =>
      emit(ProfileState(status: ProfileStatus.ready, profile: profile));

  Future<void> load({bool reuseExisting = false}) async {
    if (state.profile == null) emit(const ProfileState());
    if (!reuseExisting || state.profile == null) {
      final result = await _get(const NoParams());
      if (isClosed) return;
      result.fold(
        (f) => emit(state.copyWith(status: ProfileStatus.failure, failure: f)),
        (p) => emit(state.copyWith(status: ProfileStatus.ready, profile: p)),
      );
    }
    final history = await _history(const NoParams());
    if (isClosed) return;
    history.fold((_) {}, (d) => emit(state.copyWith(donations: d)));
  }

  /// Returns true when the server accepted the change.
  Future<bool> update(ProfileUpdate update) async {
    final result = await _update(update);
    if (isClosed) return false;
    return result.fold(
      (f) {
        emit(state.copyWith(actionFailure: f));
        return false;
      },
      (p) {
        emit(state.copyWith(profile: p));
        return true;
      },
    );
  }

  Future<bool> deleteAccount() async {
    final result = await _delete(const NoParams());
    if (isClosed) return false;
    return result.fold(
      (f) {
        emit(state.copyWith(actionFailure: f));
        return false;
      },
      (_) {
        emit(const ProfileState(status: ProfileStatus.deleted));
        return true;
      },
    );
  }

  void reset() => emit(const ProfileState());
}
