import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories_impl/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/home_feed/data/datasources/feed_remote_datasource.dart';
import '../../features/home_feed/data/repositories_impl/feed_repository_impl.dart';
import '../../features/home_feed/domain/repositories/feed_repository.dart';
import '../../features/home_feed/domain/usecases/watch_posts.dart';
import '../../features/home_feed/presentation/cubit/feed_cubit.dart';
import '../../features/blood_request/data/datasources/blood_request_remote_datasource.dart';
import '../../features/blood_request/data/repositories_impl/blood_request_repository_impl.dart';
import '../../features/blood_request/domain/repositories/blood_request_repository.dart';
import '../../features/blood_request/domain/usecases/blood_request_usecases.dart';
import '../../features/blood_request/presentation/cubit/blood_request_cubit.dart';

final getIt = GetIt.instance;
Future<void> configureDependencies() async {
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => FirebaseMessaging.instance);
  initAuth();
  initProfile();
  initHomeFeed();
  initBloodRequest();
}

void initAuth() {
  getIt.registerLazySingleton(() => AuthRemoteDataSource(getIt()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => WatchAuth(getIt()));
  getIt.registerLazySingleton(() => RequestPhoneCode(getIt()));
  getIt.registerLazySingleton(() => VerifyCode(getIt()));
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerFactory(() => AuthCubit(getIt(), getIt(), getIt(), getIt()));
}

void initProfile() {
  getIt.registerLazySingleton(() => ProfileRemoteDataSource(getIt()));
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => WatchProfile(getIt()));
  getIt.registerLazySingleton(() => SaveProfile(getIt()));
  getIt.registerFactory(() => ProfileCubit(getIt(), getIt()));
}

void initHomeFeed() {
  getIt.registerLazySingleton(() => FeedRemoteDataSource(getIt()));
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => WatchPosts(getIt()));
  getIt.registerFactory(() => FeedCubit(getIt()));
}

void initBloodRequest() {
  getIt.registerLazySingleton(
    () => BloodRequestRemoteDataSource(getIt(), getIt()),
  );
  getIt.registerLazySingleton<BloodRequestRepository>(
    () => BloodRequestRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => CreateBloodRequest(getIt()));
  getIt.registerLazySingleton(() => PledgeToDonate(getIt()));
  getIt.registerFactory(() => BloodRequestCubit(getIt(), getIt()));
}
