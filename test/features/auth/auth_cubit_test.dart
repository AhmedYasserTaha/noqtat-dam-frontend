import 'package:bloc_test/bloc_test.dart';
import 'package:damy/features/auth/domain/entities/auth_user.dart';
import 'package:damy/features/auth/domain/repositories/auth_repository.dart';
import 'package:damy/features/auth/domain/usecases/auth_usecases.dart';
import 'package:damy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:damy/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  setUp(() => repository = MockAuthRepository());
  blocTest<AuthCubit, AuthState>(
    'phone request emits loading then codeSent',
    build: () {
      when(() => repository.requestCode('+201000000000'))
          .thenAnswer((_) => Stream.value(const Right(PhoneCodeSent('id'))));
      return AuthCubit(
        WatchAuth(repository),
        RequestPhoneCode(repository),
        VerifyCode(repository),
        SignOut(repository),
      );
    },
    act: (cubit) => cubit.requestCode('+201000000000'),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.codeSent, verificationId: 'id'),
    ],
    verify: (_) =>
        verify(() => repository.requestCode('+201000000000')).called(1),
  );
  blocTest<AuthCubit, AuthState>(
    'auth stream emits authenticated user',
    build: () {
      when(() => repository.watch())
          .thenAnswer((_) => Stream.value(const Right(AuthUser(uid: 'u'))));
      return AuthCubit(
        WatchAuth(repository),
        RequestPhoneCode(repository),
        VerifyCode(repository),
        SignOut(repository),
      );
    },
    act: (cubit) => cubit.start(),
    expect: () => [
      const AuthState(
        status: AuthStatus.authenticated,
        user: AuthUser(uid: 'u'),
      ),
    ],
  );
}
