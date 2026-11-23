import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/blood_request/data/datasources/blood_request_remote_datasource.dart';
import '../../features/blood_request/data/repositories_impl/blood_request_repository_impl.dart';
import '../../features/blood_request/domain/repositories/blood_request_repository.dart';
import '../../features/blood_request/domain/usecases/blood_request_usecases.dart';
import '../../features/blood_request/presentation/cubit/blood_request_cubit.dart';
import '../../features/blood_request/presentation/cubit/my_requests_cubit.dart';
import '../../features/home_feed/data/datasources/feed_remote_datasource.dart';
import '../../features/home_feed/data/repositories_impl/feed_repository_impl.dart';
import '../../features/home_feed/domain/repositories/feed_repository.dart';
import '../../features/home_feed/domain/usecases/feed_usecases.dart';
import '../../features/home_feed/presentation/cubit/feed_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories_impl/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../config/api_config.dart';
import '../network/api_client.dart';
import '../storage/token_store.dart';

final GetIt getIt = GetIt.instance;

/// Registers everything. Pass [tokens] / [api] in tests to avoid platform
/// plugins and real network calls.
void configureDependencies({TokenStore? tokens, ApiClient? api}) {
  getIt.allowReassignment = true; // tests re-run this with fakes
  final store = tokens ?? SecureTokenStore();
  getIt
    ..registerSingleton<TokenStore>(store)
    ..registerSingleton<ApiClient>(
      api ?? ApiClient(baseUrl: apiBaseUrl, tokens: store),
    );

  // auth
  getIt
    ..registerLazySingleton(() => AuthRemoteDataSource(getIt(), getIt()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton(() => RegisterUser(getIt()))
    ..registerLazySingleton(() => LoginUser(getIt()))
    ..registerLazySingleton(() => RestoreSession(getIt()))
    ..registerLazySingleton(() => SignOut(getIt()))
    ..registerLazySingleton(() => RequestPasswordReset(getIt()))
    ..registerLazySingleton(() => ResetPassword(getIt()))
    ..registerLazySingleton(
      () => AuthCubit(
        repository: getIt(),
        restoreSession: getIt(),
        loginUser: getIt(),
        registerUser: getIt(),
        signOutUseCase: getIt(),
        requestReset: getIt(),
        resetPasswordUseCase: getIt(),
      ),
    );

  // profile
  getIt
    ..registerLazySingleton(() => ProfileRemoteDataSource(getIt(), getIt()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetProfile(getIt()))
    ..registerLazySingleton(() => UpdateProfile(getIt()))
    ..registerLazySingleton(() => GetDonationHistory(getIt()))
    ..registerLazySingleton(() => DeleteAccount(getIt()))
    ..registerLazySingleton(
      () => ProfileCubit(getIt(), getIt(), getIt(), getIt()),
    );

  // blood requests
  getIt
    ..registerLazySingleton(() => BloodRequestRemoteDataSource(getIt()))
    ..registerLazySingleton<BloodRequestRepository>(
      () => BloodRequestRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => CreateBloodRequest(getIt()))
    ..registerLazySingleton(() => GetMyRequests(getIt()))
    ..registerLazySingleton(() => UpdateMyRequest(getIt()))
    ..registerLazySingleton(() => PledgeToDonate(getIt()))
    ..registerLazySingleton(() => ReportDonated(getIt()))
    ..registerLazySingleton(() => CancelPledge(getIt()))
    ..registerFactory(() => BloodRequestCubit(getIt()))
    ..registerLazySingleton(() => MyRequestsCubit(getIt(), getIt()));

  // feed
  getIt
    ..registerLazySingleton(() => FeedRemoteDataSource(getIt()))
    ..registerLazySingleton<FeedRepository>(() => FeedRepositoryImpl(getIt()))
    ..registerLazySingleton(() => GetHome(getIt()))
    ..registerLazySingleton(() => GetFeed(getIt()))
    ..registerLazySingleton(
      () => FeedCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
    );
}
