import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/utils/push_service.dart';
import 'core/network/api_checker.dart';
import 'core/network/api_client.dart';
import 'core/widgets/api_checker_widget.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/blood_request/presentation/cubit/my_requests_cubit.dart';
import 'features/home_feed/presentation/cubit/feed_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'l10n/app_localizations.dart';

class DamyApp extends StatefulWidget {
  const DamyApp({
    super.key,
    this.locale = const Locale('ar'),
    this.onLocaleChanged,
  });
  final Locale locale;
  final ValueChanged<Locale>? onLocaleChanged;
  static void setLocale(BuildContext context, Locale locale) {
    context.findAncestorStateOfType<_DamyAppState>()?._setLocale(locale);
  }

  @override
  State<DamyApp> createState() => _DamyAppState();
}

class _DamyAppState extends State<DamyApp> {
  late Locale _locale = widget.locale;

  void _setLocale(Locale locale) {
    getIt<ApiClient>().languageCode = locale.languageCode;
    setState(() => _locale = locale);
    widget.onLocaleChanged?.call(locale);
  }

  late final AuthCubit _auth = getIt<AuthCubit>();
  late final RouterRefresh _refresh = RouterRefresh(_auth.stream);
  late final GoRouter _router = createRouter(_auth, _refresh);

  @override
  void initState() {
    super.initState();
    getIt<ApiClient>().languageCode = widget.locale.languageCode;
    _auth.start();
    // A push while the app is open: refresh the feed (and its bell badge).
    _foreground = getIt<PushService>().foregroundMessages.listen(
      (_) => getIt<FeedCubit>().load(),
    );
  }

  StreamSubscription<void>? _foreground;

  @override
  void didUpdateWidget(covariant DamyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      _locale = widget.locale;
      getIt<ApiClient>().languageCode = widget.locale.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: _auth),
      BlocProvider<ProfileCubit>.value(value: getIt<ProfileCubit>()),
      BlocProvider<FeedCubit>.value(value: getIt<FeedCubit>()),
      BlocProvider<MyRequestsCubit>.value(value: getIt<MyRequestsCubit>()),
    ],
    child: BlocListener<AuthCubit, AuthState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == AuthStatus.unauthenticated,
      // Drop the previous account's data when the session ends.
      listener: (context, _) {
        getIt<ProfileCubit>().reset();
        getIt<FeedCubit>().reset();
        getIt<MyRequestsCubit>().reset();
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        builder: (context, child) => ApiCheckerWidget(
          isActive: ApiChecker.isActive,
          onPressed: ApiChecker.openInspector,
          child: child ?? const SizedBox.shrink(),
        ),
        theme: AppTheme.light,
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      ),
    ),
  );

  @override
  void dispose() {
    _foreground?.cancel();
    _router.dispose();
    _refresh.dispose();
    super.dispose();
  }
}
