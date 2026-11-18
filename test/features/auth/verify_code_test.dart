import 'package:damy/core/errors/failures.dart';
import 'package:damy/features/auth/domain/repositories/auth_repository.dart';
import 'package:damy/features/auth/domain/usecases/auth_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test(
    'VerifyCode forwards credentials and preserves the repository failure',
    () async {
      final repository = MockAuthRepository();
      const failure = AuthFailure('invalid-verification-code');
      when(() => repository.verify('verification', '000000'))
          .thenAnswer((_) async => const Left(failure));
      final result = await VerifyCode(repository)(
        const VerifyCodeParams('verification', '000000'),
      );
      expect(result, const Left<Failure, Unit>(failure));
      verify(() => repository.verify('verification', '000000')).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
