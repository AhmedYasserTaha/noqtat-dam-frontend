import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import 'app_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/cubit/profile_state.dart';
import '../../features/home_feed/presentation/cubit/feed_cubit.dart';
import '../../features/blood_request/presentation/cubit/blood_request_cubit.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/home_feed/presentation/pages/home_feed_page.dart';
import '../../features/blood_request/presentation/pages/blood_request_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(AuthCubit auth, ProfileCubit profile) {
    _auth = auth.stream.listen((_) => notifyListeners());
    _profile = profile.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<Object?> _auth, _profile;
  @override
  void dispose() {
    unawaited(_auth.cancel());
    unawaited(_profile.cancel());
    super.dispose();
  }
}

String? authRedirect(AuthState auth, ProfileState profile, String location) {
  if (auth.status == AuthStatus.initial) {
    return location == '/loading' ? null : '/loading';
  }
  const publicAuthRoutes = ['/auth', '/auth/register', '/auth/forgot-password'];
  if (auth.user == null) {
    return publicAuthRoutes.contains(location) ? null : '/auth';
  }
  if (profile.status != ProfileStatus.loaded) {
    return location == '/loading' ? null : '/loading';
  }
  if (!profile.isComplete) {
    return location == '/complete-profile' ? null : '/complete-profile';
  }
  if ([
    ...publicAuthRoutes,
    '/complete-profile',
    '/loading',
  ].contains(location)) {
    return '/';
  }
  return null;
}

GoRouter createRouter(
  AuthCubit auth,
  ProfileCubit profile,
  RouterRefresh refresh,
) => GoRouter(
  initialLocation: '/loading',
  refreshListenable: refresh,
  redirect: (context, state) =>
      authRedirect(auth.state, profile.state, state.uri.path),
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => Scaffold(
        body: Center(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => state.status == ProfileStatus.failure
                ? TextButton(
                    onPressed: () => profile.watch(auth.state.user?.uid),
                    child: Text(AppLocalizations.of(context)!.retry),
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfilePage(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<FeedCubit>(),
            child: const HomeFeedPage(),
          ),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) =>
              PendingTabPage(title: AppLocalizations.of(context)!.mapTab),
        ),
        GoRoute(
          path: '/requests',
          builder: (context, state) => PendingTabPage(
            title: AppLocalizations.of(context)!.myRequestsTab,
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/blood-request',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BloodRequestCubit>(),
        child: const BloodRequestPage(),
      ),
    ),
  ],
);
