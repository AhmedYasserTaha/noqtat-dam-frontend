import 'package:damy/core/router/app_router.dart';
import 'package:damy/features/auth/domain/entities/auth_user.dart';
import 'package:damy/features/auth/presentation/cubit/auth_state.dart';
import 'package:damy/features/profile/domain/entities/user_profile.dart';
import 'package:damy/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anonymous users can open registration and recovery', () {
    for (final route in ['/auth/register', '/auth/forgot-password']) {
      expect(
        authRedirect(
          const AuthState(status: AuthStatus.unauthenticated),
          const ProfileState(),
          route,
        ),
        isNull,
      );
    }
  });
  const authenticated = AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(uid: 'u'),
  );
  test('anonymous deep links require login', () {
    expect(
      authRedirect(
        const AuthState(status: AuthStatus.unauthenticated),
        const ProfileState(),
        '/blood-request',
      ),
      '/auth',
    );
  });
  test('profile lookup must finish before deciding whether to complete it', () {
    expect(
      authRedirect(
        authenticated,
        const ProfileState(status: ProfileStatus.loading),
        '/',
      ),
      '/loading',
    );
  });
  test('missing profile requires completion', () {
    expect(
      authRedirect(
        authenticated,
        const ProfileState(status: ProfileStatus.loaded),
        '/',
      ),
      '/complete-profile',
    );
  });
  test('complete profile unlocks protected routes', () {
    final profile = ProfileState(
      status: ProfileStatus.loaded,
      profile: UserProfile(
        uid: 'u',
        name: 'Donor',
        phone: '+201000000000',
        bloodType: 'O+',
        governorate: 'Cairo',
        city: '',
        isAvailable: true,
        donationsCount: 0,
        createdAt: DateTime(2026),
      ),
    );
    expect(authRedirect(authenticated, profile, '/blood-request'), isNull);
    expect(authRedirect(authenticated, profile, '/complete-profile'), '/');
  });
}
