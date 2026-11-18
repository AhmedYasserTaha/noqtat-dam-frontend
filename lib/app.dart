import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'l10n/app_localizations.dart';

class DamyApp extends StatefulWidget {
  const DamyApp({super.key, this.locale = const Locale('ar')});
  final Locale locale;
  @override
  State<DamyApp> createState() => _DamyAppState();
}

class _DamyAppState extends State<DamyApp> {
  late final AuthCubit _auth;
  late final ProfileCubit _profile;
  late final RouterRefresh _refresh;
  late final GoRouter _router;
  late final StreamSubscription<Object?> _session;
  String? _uid;
  @override
  void initState() {
    super.initState();
    _auth = getIt<AuthCubit>();
    _profile = getIt<ProfileCubit>();
    _session = _auth.stream.listen((state) {
      final uid = state.user?.uid;
      if (uid != _uid) {
        _uid = uid;
        unawaited(_profile.watch(uid));
      }
    });
    _refresh = RouterRefresh(_auth, _profile);
    _router = createRouter(_auth, _profile, _refresh);
    _auth.start();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: _auth),
      BlocProvider.value(value: _profile),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
      locale: widget.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
    ),
  );
  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    unawaited(_session.cancel());
    unawaited(_auth.close());
    unawaited(_profile.close());
    super.dispose();
  }
}
