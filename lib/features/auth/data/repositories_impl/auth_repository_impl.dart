import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_failure_mapper.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remote);
  final AuthRemoteDataSource remote;
  @override
  Stream<Either<Failure, AuthUser?>> watch() async* {
    try {
      await for (final user in remote.watch()) {
        yield Right(
          user == null
              ? null
              : AuthUserModel(uid: user.uid, phone: user.phoneNumber),
        );
      }
    } catch (e) {
      yield Left(mapFailure(e));
    }
  }

  @override
  Stream<Either<Failure, PhoneEvent>> requestCode(String phone) {
    late final StreamController<Either<Failure, PhoneEvent>> controller;
    void send(Either<Failure, PhoneEvent> event) {
      if (!controller.isClosed) controller.add(event);
    }

    Future<void> finish(Either<Failure, PhoneEvent> event) async {
      send(event);
      await controller.close();
    }

    controller = StreamController(
      onListen: () async {
        try {
          await remote.auth.verifyPhoneNumber(
            phoneNumber: phone,
            verificationCompleted: (credential) async {
              try {
                await remote.auth.signInWithCredential(credential);
                await finish(const Right(PhoneVerified()));
              } catch (e) {
                await finish(Left(mapFailure(e)));
              }
            },
            verificationFailed: (error) {
              unawaited(finish(Left(mapFailure(error))));
            },
            codeSent: (id, token) {
              send(Right(PhoneCodeSent(id)));
            },
            codeAutoRetrievalTimeout: (id) {
              unawaited(finish(Right(PhoneCodeSent(id))));
            },
          );
        } catch (e) {
          await finish(Left(mapFailure(e)));
        }
      },
      onCancel: () {
        if (!controller.isClosed) unawaited(controller.close());
      },
    );
    return controller.stream;
  }

  @override
  Future<Either<Failure, Unit>> verify(String id, String code) async {
    try {
      await remote.verify(id, code);
      return const Right(unit);
    } catch (e) {
      return Left(mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remote.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(mapFailure(e));
    }
  }
}
