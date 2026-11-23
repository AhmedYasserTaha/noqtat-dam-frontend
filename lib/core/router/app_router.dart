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
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/home_feed/presentation/pages/home_feed_page.dart';
import '../../features/blood_request/presentation/pages/blood_request_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/info_page.dart';
import '../../features/blood_request/presentation/pages/my_requests_page.dart';

/// Re-runs the router redirect whenever the auth state changes.
class RouterRefresh extends ChangeNotifier {
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

GoRouter createRouter(AuthCubit auth, Listenable refresh) => GoRouter(
  navigatorKey: ApiChecker.navigatorKey,
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (context, state) => authRedirect(auth.state, state.uri.path),
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
  ],
);
