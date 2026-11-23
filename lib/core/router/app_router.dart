import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/home_feed/presentation/pages/home_feed_page.dart';
import '../../features/blood_request/presentation/pages/blood_request_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [
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
      builder: (context, state) => const BloodRequestPage(),
    ),
  ],
);
