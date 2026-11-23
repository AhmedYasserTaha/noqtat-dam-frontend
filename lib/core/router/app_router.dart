import 'package:go_router/go_router.dart';

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

GoRouter createRouter() => GoRouter(
  initialLocation: '/auth',
  routes: [
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
      builder: (context, state) => const BloodRequestPage(),
    ),
  ],
);
