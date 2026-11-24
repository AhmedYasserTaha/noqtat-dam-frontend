import 'package:get_it/get_it.dart';

import '../network/locations_api.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/profile/data/models/user_profile_model.dart';
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
import '../../features/blood_request/presentation/cubit/pledges_cubit.dart';
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
import '../../features/community/data/datasources/community_remote_datasource.dart';
import '../../features/community/data/repositories_impl/community_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/usecases/community_usecases.dart';
import '../../features/community/presentation/cubit/create_post_cubit.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories_impl/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/notifications_usecases.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../utils/push_registrar.dart';
import '../utils/push_service.dart';
import '../utils/share_service.dart';
import '../../features/hospitals/data/datasources/hospital_remote_datasource.dart';
import '../../features/hospitals/data/repositories_impl/hospital_repository_impl.dart';
import '../../features/hospitals/domain/repositories/hospital_repository.dart';
import '../../features/hospitals/domain/usecases/get_hospitals.dart';
import '../../features/hospitals/presentation/cubit/hospital_list_cubit.dart';
import '../utils/device_location.dart';
import '../utils/maps_launcher.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../storage/token_store.dart';

final GetIt getIt = GetIt.instance;

/// Registers everything. Pass [tokens] / [api] in tests to avoid platform
/// plugins and real network calls.
void configureDependencies({
  TokenStore? tokens,
  ApiClient? api,
  ShareService? share,
  MapsLauncher? maps,
  DeviceLocation? location,
  PushService? push,
}) {
  getIt.allowReassignment = true; // tests re-run this with fakes
  final store = tokens ?? SecureTokenStore();
  getIt
    ..registerSingleton<TokenStore>(store)
    ..registerSingleton<ApiClient>(
      api ?? ApiClient(baseUrl: ApiConstants.baseUrl, tokens: store),
    );

  getIt.registerLazySingleton(() => LocationsApi(getIt<ApiClient>()));

  getIt
    ..registerSingleton<PushService>(push ?? const NoopPushService())
    ..registerLazySingleton(() => PushRegistrar(getIt(), getIt()));

  // auth
  getIt
    ..registerLazySingleton(
      () => AuthRemoteDataSource(
        getIt(),
        getIt(),
        onSessionRestored: (json) =>
            getIt<ProfileCubit>().seed(UserProfileModel.fromJson(json)),
      ),
    )
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
        beforeSignOut: () => getIt<PushRegistrar>().beforeSignOut(),
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
    ..registerLazySingleton(() => ChangePassword(getIt()))
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
    ..registerLazySingleton(() => GetRequestPledges(getIt()))
    ..registerFactory(() => PledgesCubit(getIt()))
    ..registerFactory(() => BloodRequestCubit(getIt()))
    ..registerLazySingleton(() => MyRequestsCubit(getIt(), getIt()));

  // feed
  getIt
    ..registerLazySingleton(() => FeedRemoteDataSource(getIt()))
    ..registerLazySingleton<FeedRepository>(() => FeedRepositoryImpl(getIt()))
    ..registerLazySingleton(() => GetHome(getIt()))
    ..registerLazySingleton(() => GetFeed(getIt()))
    ..registerLazySingleton(() => GetPosts(getIt()))
    ..registerLazySingleton(
      () => FeedCubit(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    );

  // hospital directory
  getIt
    ..registerLazySingleton(() => HospitalRemoteDataSource(getIt()))
    ..registerLazySingleton<HospitalRepository>(
      () => HospitalRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetHospitals(getIt()))
    ..registerFactory(() => HospitalListCubit(getIt()));

  // community posts
  getIt
    ..registerSingleton<ShareService>(share ?? const SharePlusShareService())
    ..registerSingleton<DeviceLocation>(
      location ?? const GeolocatorDeviceLocation(),
    )
    ..registerSingleton<MapsLauncher>(maps ?? const UrlLauncherMapsLauncher())
    ..registerLazySingleton(() => CommunityRemoteDataSource(getIt()))
    ..registerLazySingleton<CommunityRepository>(
      () => CommunityRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => CreatePost(getIt()))
    ..registerLazySingleton(() => UpdatePost(getIt()))
    ..registerLazySingleton(() => ReactToPost(getIt()))
    ..registerLazySingleton(() => DeletePost(getIt()))
    ..registerLazySingleton(() => ReportContent(getIt()))
    ..registerFactory(() => CreatePostCubit(getIt()));

  // notifications inbox
  getIt
    ..registerLazySingleton(() => NotificationsRemoteDataSource(getIt()))
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetNotifications(getIt()))
    ..registerLazySingleton(() => MarkNotificationsRead(getIt()))
    ..registerFactory(() => NotificationsCubit(getIt(), getIt()));
}
