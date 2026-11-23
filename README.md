# Damy — UI only

Arabic-first Flutter UI prototype. Opens on the login screen. Login or
registration forms navigate to Home locally, without real authentication,
dependency injection or feature backend requests.
Firebase remains connected and initialized in main.dart using the original
project configuration. The Firebase packages and local rules/index files are
retained for future feature implementation.

## Included

- Login, registration and password-recovery forms without validation or required fields.
- Home preview, sample cards, filters and independent bottom navigation.
- Static my-requests tabs (active/completed/cancelled) with preview detail sheets.
- Profile with sample personal/donation details, donation history, temporary name
  and phone edits, local availability/notification toggles and logout navigation.
- Privacy/terms draft pages, help/FAQ, app information and a simulated delete-account
  confirmation. No real deletion or profile writes. Policy text is preview copy.
- Create-request UI with blood type, bag count, hospital, location, urgency,
  optional date/time, phone and notes. Review/edit/confirm flow is local only;
  confirmation does not publish, save, notify or change the static request list.
- Placeholder complete-profile page. The map tab is currently removed.
- White theme, bundled Cairo fonts, project SVG icons, Arabic RTL and English.
- Offline governorate/district selectors. Data source, license and revision:
  assets/data/egypt/README.md.

Only presentation folders remain under lib/features. Shared UI, routes, theme,
constants and offline location utilities live in lib/core. Form input,
local selection/filtering and navigation remain so the prototype is interactive.

Repositories, data sources, domain models, use cases, Cubits and DI have been
removed locally. Firebase connection/configuration is retained. No remote Firebase resources
were changed. There is no real login, saved profile, request creation, donation
pledge, push messaging or live feed. Submission buttons show an unavailable or
preview notice; sharing copies explicitly labeled sample text.

## Run and verify

```sh
flutter pub get
flutter gen-l10n
flutter run
flutter analyze
flutter test
```

Application ID: com.codex.dammak. Restart the running app after dependency changes.
