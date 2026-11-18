# Damy

Arabic-first blood donation app scaffold. Setup only: all feature pages are
placeholders. Phone/OTP and profile completion have no forms yet.

## Architecture

Feature-first Clean Architecture lives in `lib/features/{auth,home_feed,blood_request,profile}`:

- `domain`: plain Dart entities, repository contracts and use cases; no Flutter or Firebase imports.
- `data`: Firebase data sources, map models and repository implementations. Firebase errors become sealed `Failure` values through `Either`.
- `presentation`: Cubits/states and placeholder pages. Cubits call use cases only.

`core` contains DI (`configureDependencies`, one initializer per feature), routing,
theme tokens, shared widgets, constants and utilities. Firebase exception mapping
is separate from the pure-Dart Failure hierarchy. Models use Equatable; no model
code generation. ARB localization generation is enabled.

`DamyApp` defaults to Arabic; localization delegates supply RTL. Pass
`locale: Locale('en')` for English. Cairo 400/600/700/900 is bundled locally under
`assets/fonts` with its OFL license. SVG files are intentionally absent; put the
20 expected assets listed in `AppIcons` into `assets/icons` before using them.

## Local verification

```sh
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
```

Dependency constraints were resolved using installed Flutter 3.47.9 / Dart
3.13.7. Commit `pubspec.lock` for reproducible application builds.

## Connect Firebase (manual)

Install the Firebase CLI and authenticate, then run from the project root:

```sh
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Select your real Firebase project and Android/iOS apps. This replaces the
deliberately throwing `lib/firebase_options.dart` placeholder. The app cannot
start until configuration exists. Check generated platform configuration files;
do not use sample Firebase credentials. If the FlutterFire executable is missing,
add the Dart pub-cache `bin` directory to PATH.

In the Firebase console:

1. Enable **Authentication → Sign-in method → Phone**; configure allowed SMS
   regions, billing/quota requirements and test numbers.
2. Create Cloud Firestore and Cloud Storage in the intended region.
3. Add Android SHA-1/SHA-256 fingerprints for phone verification; select your
   actual application ID before registering production apps.
4. Configure Cloud Messaging/APNs for iOS as described below.

Deploy the provided configuration, explicitly choosing your project:

```sh
firebase deploy --project YOUR_PROJECT_ID --only firestore:rules,firestore:indexes,storage
flutter run
```

Rules allow users to access their own profile, authenticated post reads, and
author-only post mutations. Post documents reject extra fields so contact phone
numbers cannot be added to the public post schema. Contact lives only at
`posts/{id}/private/contact`; the author and active/donated pledgers may read it.
Cancelled pledges lose contact access. Request creation writes public data and
private contact atomically. Verification and engagement counters are reserved
for trusted server updates. Comments/likes have paths and models, with client
writes deferred. Storage defaults to deny-all until an upload flow is designed.
Review and emulator-test rules before production deployment; the Dart tests do
not execute Firebase rules. Deleting a Firestore post does not cascade to its
subcollections; production cleanup needs a trusted backend.

## Platform setup

Android `minSdk` is 24 for the resolved Firebase packages. Internet permission
is declared in the main manifest. Configure real release signing before shipping.

iOS deployment target is already 15.0 in this project. If using CocoaPods, set
`platform :ios, '15.0'` in the Podfile and run `pod install` on macOS. This project
does not currently include a Podfile; keep its generated Swift Package Manager
setup unless intentionally migrating to CocoaPods. In Xcode enable Push
Notifications and Background Modes → Remote notifications, upload an APNs key
to Firebase, and configure the phone-auth reCAPTCHA URL scheme from the generated
GoogleService-Info.plist (reversed client ID). Test phone authentication and push
on a real device. No signing or credential steps were run here.

Messaging has a background entry point and DI registration. Notification
permission prompts, token storage/refresh, foreground display and Storage upload
flows are deferred until their UI/use cases are implemented.

## Skeleton behavior and assumptions

- Firebase auth state drives routing. Unauthenticated routes go to `/auth`.
  Authenticated users wait for their private profile document; missing/incomplete
  name, blood type or governorate routes to `/complete-profile`. Profile read
  failures show a retry action instead of treating an error as a missing profile.
- Phone auth uses the native Android/iOS verification flow. Web phone auth is
  deferred. OTP verification errors retain the verification ID for retry.
- Feed queries stream the first 20 posts by `createdAt` descending, using document
  ID as a deterministic tie breaker. `loadMore` uses a typed timestamp/ID cursor
  and Firestore `startAfter`. Paging freezes the first-page subscription to avoid
  changing cursor boundaries; calling `load()` refreshes and restores live mode.
  Pages remain placeholders and do not initiate feature requests yet.
- Post types, urgency, request/pledge statuses use their specified wire strings.
  User/post document IDs are injected into model maps on reads and excluded from
  profile writes. Normal and blood-request posts share the feed `PostModel`.
- Server timestamps are used for requests/pledges. Client profile saves currently
  accept a creation date; donation totals are scaffolding, not verified statistics.

Reference: [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup).
