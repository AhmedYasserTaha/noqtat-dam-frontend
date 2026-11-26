import '../../l10n/app_localizations.dart';
import '../errors/failures.dart';
import '../network/api_client.dart';

/// Turns a [Failure] into localized user copy.
String failureMessage(AppLocalizations t, Failure f) {
  if (f.message?.trim().isNotEmpty == true) return f.message!;
  switch (f) {
    case NetworkFailure():
      return t.errNetwork;
    case ServerFailure():
      return t.errServer;
    case NotFoundFailure():
      return t.errNotFound;
    case PermissionFailure():
      return t.errPermission;
    default:
      break;
  }
  return switch (f.code) {
    ApiErrorCodes.invalidPhone => t.errInvalidPhone,
    ApiErrorCodes.weakPassword => t.errWeakPassword,
    ApiErrorCodes.phoneTaken => t.errPhoneTaken,
    ApiErrorCodes.wrongCredentials => t.errWrongCredentials,
    ApiErrorCodes.invalidCode => t.errInvalidCode,
    ApiErrorCodes.needGovernorate => t.errNeedGovernorate,
    ApiErrorCodes.tooManyAttempts => t.errTooMany,
    ApiErrorCodes.alreadyPledged => t.errAlreadyPledged,
    'unauthorized' => t.errUnauthorized,
    _ => t.errGeneric,
  };
}
