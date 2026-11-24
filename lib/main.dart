import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/network/api_checker.dart';
import 'core/utils/push_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ApiChecker.init(environment: AppEnvironment.dev);
  configureDependencies(push: FirebasePushService());
  const storage = FlutterSecureStorage();
  final language = await storage.read(key: 'app_language');
  runApp(
    DamyApp(
      locale: Locale(language == 'en' ? 'en' : 'ar'),
      onLocaleChanged: (locale) async {
        await storage.write(key: 'app_language', value: locale.languageCode);
      },
    ),
  );
}
