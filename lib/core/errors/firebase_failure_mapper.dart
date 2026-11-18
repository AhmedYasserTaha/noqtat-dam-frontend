import 'package:firebase_core/firebase_core.dart';

import 'failures.dart';

Failure mapFailure(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'network-request-failed' || 'unavailable' => NetworkFailure(error.code),
      'permission-denied' => PermissionFailure(error.code),
      _ =>
        error.plugin == 'firebase_auth'
            ? AuthFailure(error.code)
            : UnexpectedFailure(error.code),
    };
  }
  return const UnexpectedFailure();
}
