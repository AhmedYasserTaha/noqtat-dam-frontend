# Damy (قطره دم)

Arabic-first Flutter app for blood requests and donors, connected to the
[noqtat-dam-backend](https://github.com/AhmedYasserTaha/noqtat-dam-backend)
REST API (Node/Express/PostgreSQL).

## What works against the API

- Register / login with an Egyptian mobile number and password. The session
  token is kept in secure storage and restored on launch. A 401 signs the user out.
- Forgot password: request a code, then reset. **Dev stub only.** The backend
  prints the code in its server log; no SMS is sent until a provider is added.
- Home feed: closest urgent request, filters All / Urgent / My blood (exact blood
  type) / Nearby (needs a governorate in the profile), community posts.
- "I will donate" pledges, which unlocks the requester's phone. "I donated" is
  the donor's own record. Nothing in the app verifies a donation.
- Create request, My requests (active / completed / cancelled), and the author's
  controls: bags collected, mark fulfilled, cancel.
- Create button asks: normal post or blood request. Posts show as regular cards
  with explicit like / dislike (tap again to undo). Authors can delete their post.
- Share a request through the system share sheet (`share_plus`). The text has
  no phone number.
- Report a request or post (5 reasons). It is hidden **for the reporter only**;
  there is no moderation service, the app owner reviews reports by hand.
- Feed pagination (load more, with retry that keeps what is already loaded).
- Notifications inbox (bell badge): new request in your governorate, someone
  pledged, a donor self-reported, request closed.
- Request authors see who pledged (name, blood type, status; no phone numbers).
- Push client: asks permission, sends the device token to the backend after
  sign-in, clears it before sign-out. The backend only sends once it has a
  Firebase service account.
- Profile: edit name/phone, availability and notification preferences, donation
  history (self-reported), logout, delete account.

The app does not decide donor eligibility or blood-type compatibility. The
hospital's medical staff do.

## Architecture

Clean Architecture per feature, no network calls in widgets:

```
lib/core/{config,di,errors,network,storage,usecase,utils,router,widgets,theme}
lib/features/<feature>/
  domain/{entities,repositories,usecases}
  data/{datasources,models,repositories_impl}
  presentation/{cubit,pages,widgets}
```

flutter_bloc Cubits, get_it for DI (`lib/core/di/injection.dart`), fpdart
`Either<Failure, T>` results, equatable, Dio for HTTP.

Firebase is still initialized in `main.dart` and its packages and rules files are
untouched. No feature calls Firebase.

## Run

```sh
flutter pub get
flutter gen-l10n
# Android emulator reaches the host machine at 10.0.2.2 (the default):
flutter run
# Physical device or other host:
flutter run --dart-define=API_BASE_URL=http://<your-computer-ip>:3000
```

- Start the backend first (see its README; it needs a PostgreSQL database created
  from `schema.sql` on a fresh, empty database).
- Debug Android builds allow cleartext HTTP (`android/app/src/debug`). Release
  builds need an HTTPS `API_BASE_URL`.
- iOS needs its own App Transport Security exception for plain HTTP in debug.
  Not set up or tested.

## Test

```sh
flutter analyze
flutter test
```

The widget and data-layer tests run the real Dio client, repositories, use cases
and Cubits against an in-process fake backend (`test/helpers/fake_backend.dart`).

`test/e2e/live_backend_test.dart` runs the same data layer against a running
backend and is skipped unless `E2E_API_URL` and `E2E_SMS_LOG` are set:

```sh
E2E_API_URL=http://127.0.0.1:3000 E2E_SMS_LOG=/path/to/server.log flutter test test/e2e
```

## Not done / not verified

- Push (FCM) was never run on a real device. Backend needs the Firebase service
  account in its `.env`. iOS also needs an APNs key uploaded in Firebase and the
  Push capability in Xcode; none of that is set up.
- SMS password-reset needs a paid provider on the backend; still dev-log only.
- Not run on iOS or on a real Android device. Hosting/HTTPS not set up.
- Reports are not moderated automatically.
Application ID: com.codex.dammak.
