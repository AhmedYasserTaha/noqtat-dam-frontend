import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../network/api_checker.dart';
import '../../features/blood_request/presentation/cubit/blood_request_cubit.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

import 'app_shell.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/community/presentation/cubit/create_post_cubit.dart';
import '../../features/community/presentation/cubit/posts_cubit.dart';
import '../../features/community/presentation/pages/posts_page.dart';
import '../../features/home_feed/domain/usecases/feed_usecases.dart';
import '../../features/community/presentation/pages/create_hub_page.dart';
import '../../features/community/presentation/pages/new_post_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/home_feed/presentation/pages/home_feed_page.dart';
import '../../features/blood_request/presentation/pages/blood_request_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/info_page.dart';
import '../../features/blood_request/presentation/pages/my_requests_page.dart';
import '../../features/blood_request/presentation/pages/my_donations_page.dart';

/// Re-runs the router redirect whenever the auth state changes.
class RouterRefresh extends ChangeNotifier {
  bool splashFinished = false;

  void finishSplash() {
    if (splashFinished) return;
    splashFinished = true;
    notifyListeners();
  }

  RouterRefresh(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

const _publicPaths = {'/privacy', '/terms', '/about', '/help'};

String? authRedirect(AuthState auth, String path) {
  if (auth.status == AuthStatus.initial) {
    return path == '/splash' ? null : '/splash';
  }
  if (_publicPaths.contains(path)) return null;
  final signedIn = auth.status == AuthStatus.authenticated;
  final onAuth = path.startsWith('/auth') || path == '/splash';
  if (!signedIn && !onAuth) return '/auth';
  // A failed login or register keeps the user on the form.
  if (signedIn && onAuth) return '/';
  if (!signedIn && path == '/splash') return '/auth';
  return null;
}

GoRouter createRouter(AuthCubit auth, RouterRefresh refresh) => GoRouter(
  navigatorKey: ApiChecker.navigatorKey(),
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (context, state) {
    if (!refresh.splashFinished) {
      return state.uri.path == '/splash' ? null : '/splash';
    }
    return authRedirect(auth.state, state.uri.path);
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashPage(onFinished: refresh.finishSplash),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const InfoPage(kind: ProfileInfo.privacy),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const InfoPage(kind: ProfileInfo.terms),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const InfoPage(kind: ProfileInfo.about),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const InfoPage(kind: ProfileInfo.help),
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
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeFeedPage()),
        GoRoute(
          path: '/requests',
          builder: (context, state) => const MyRequestsPage(),
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
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateHubPage(),
    ),
    GoRoute(
      path: '/new-post',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<CreatePostCubit>(),
        child: const NewPostPage(),
      ),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => BlocProvider(
        create: (_) => PostsCubit(getIt<GetPosts>())..load(),
        child: const PostsPage(),
      ),
    ),
    GoRoute(
      path: '/my-donations',
      builder: (context, state) => const MyDonationsPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<NotificationsCubit>(),
        child: const NotificationsPageView(),
      ),
    ),
  ],
);
