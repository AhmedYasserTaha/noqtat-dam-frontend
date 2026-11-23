import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.repository,
    required this.restoreSession,
    required this.loginUser,
    required this.registerUser,
    required this.signOutUseCase,
    required this.requestReset,
    required this.resetPasswordUseCase,
  }) : super(const AuthState());

  final AuthRepository repository;
  final RestoreSession restoreSession;
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final SignOut signOutUseCase;
  final RequestPasswordReset requestReset;
  final ResetPassword resetPasswordUseCase;
  StreamSubscription<void>? _expired;

  /// Call once at app start.
  Future<void> start() async {
    _expired ??= repository.sessionExpired.listen((_) {
      if (!isClosed && state.user != null) {
        unawaited(signOut());
      }
    });
    final result = await restoreSession(const NoParams());
    if (isClosed) return;
    result.fold(
      // Offline at start with a saved token: keep the user out of the app
      // rather than guess. They can retry by logging in.
      (f) => emit(AuthState(status: AuthStatus.unauthenticated, failure: f)),
      (user) => emit(
        user == null
            ? const AuthState(status: AuthStatus.unauthenticated)
            : AuthState(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> login(String phone, String password) async {
    emit(const AuthState(status: AuthStatus.loading));
    _applySession(await loginUser(LoginParams(phone, password)));
  }

  Future<void> register(RegisterData data) async {
    emit(const AuthState(status: AuthStatus.loading));
    _applySession(await registerUser(data));
  }

  Future<void> signOut() async {
    await signOutUseCase(const NoParams());
    if (isClosed) return;
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> requestPasswordReset(String phone) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await requestReset(phone);
    if (isClosed) return;
    result.fold(
      (f) => emit(AuthState(status: AuthStatus.failure, failure: f)),
      (_) => emit(const AuthState(status: AuthStatus.resetCodeRequested)),
    );
  }

  Future<void> resetPassword(String phone, String code, String password) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await resetPasswordUseCase(
      ResetPasswordParams(phone, code, password),
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(AuthState(status: AuthStatus.failure, failure: f)),
      (_) => emit(const AuthState(status: AuthStatus.resetDone)),
    );
  }

  /// Clears an error or finished reset so a screen can start fresh.
  void clearStatus() {
    if (state.user == null && state.status != AuthStatus.unauthenticated) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  void _applySession(Either<Failure, AuthUser> result) {
    if (isClosed) return;
    result.fold(
      (f) => emit(AuthState(status: AuthStatus.failure, failure: f)),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  @override
  Future<void> close() async {
    await _expired?.cancel();
    return super.close();
  }
}
