import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class DamyApp extends StatefulWidget {
  const DamyApp({super.key, this.locale = const Locale('ar')});
  final Locale locale;
  @override
  State<DamyApp> createState() => _DamyAppState();
}

class _DamyAppState extends State<DamyApp> {
  late final GoRouter _router = createRouter();
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
    theme: AppTheme.light,
    locale: widget.locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
  );
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }
}
