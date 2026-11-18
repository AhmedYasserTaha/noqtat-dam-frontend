import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this.watchAuth,
    this.requestPhoneCode,
    this.verifyCode,
    this.signOutUseCase,
  ) : super(const AuthState());
  final WatchAuth watchAuth;
  final RequestPhoneCode requestPhoneCode;
  final VerifyCode verifyCode;
  final SignOut signOutUseCase;
  StreamSubscription<Object?>? _auth, _phone;
  void start() {
    _auth ??= watchAuth().listen((result) {
      if (isClosed) return;
      result.fold(
        (f) => emit(AuthState(status: AuthStatus.failure, failure: f)),
        (user) => emit(
          AuthState(
            status: user == null
                ? AuthStatus.unauthenticated
                : AuthStatus.authenticated,
            user: user,
          ),
        ),
      );
    });
  }

  Future<void> requestCode(String phone) async {
    emit(const AuthState(status: AuthStatus.loading));
    await _phone?.cancel();
    if (isClosed) return;
    _phone = requestPhoneCode(phone).listen((result) {
      if (isClosed || state.user != null) return;
      result.fold(
        (f) => emit(AuthState(status: AuthStatus.failure, failure: f)),
        (event) {
          if (event is PhoneCodeSent) {
            emit(
              AuthState(
                status: AuthStatus.codeSent,
                verificationId: event.verificationId,
              ),
            );
          }
        },
      );
    });
  }

  Future<void> verify(String id, String code) async {
    emit(AuthState(status: AuthStatus.loading, verificationId: id));
    final result = await verifyCode(VerifyCodeParams(id, code));
    if (isClosed) return;
    result.fold(
      (f) => emit(
        AuthState(status: AuthStatus.failure, failure: f, verificationId: id),
      ),
      (_) {},
    );
  }

  Future<void> signOut() async {
    final result = await signOutUseCase(const NoParams());
    if (isClosed) return;
    result.fold(
      (f) => emit(
        AuthState(status: AuthStatus.failure, failure: f, user: state.user),
      ),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _phone?.cancel();
    await _auth?.cancel();
    return super.close();
  }
}
