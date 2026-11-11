# Week 12: Survive a Restart

Run it with:

```
flutter run -t lib/week12/main.dart
```

This is the week 11 app copied into `week12/` and extended, so week 11 stays as it was submitted.

## Level 1: Package verdicts

- **shared_preferences**: verified publisher flutter.dev, last release October 2026 (2.5.6), all six platforms, 160/160 points, issues live in the big flutter/flutter tracker and flutter/packages gets commits every day, depends only on its own platform packages, BSD-3-Clause.
- **flutter_secure_storage**: verified publisher steenbakker.dev (one maintainer, not Google), last release September 2026 (11.2.0), all six platforms, 160/160 points, 24 open issues and a commit today, depends on its own platform packages and `meta`, BSD-3-Clause.
- **path_provider**: verified publisher flutter.dev, last release June 2026 (2.1.6), five platforms (no web, there is no file system there), 160/160 points, same flutter/packages repo, depends only on its own platform packages, BSD-3-Clause.
- **image_picker**: verified publisher flutter.dev, last release October 2026 (1.2.4), all six platforms, 160/160 points, same flutter/packages repo, depends on its own platform packages (and `file_selector` on desktop), Apache-2.0 / BSD-3-Clause.
- **permission_handler**: verified publisher baseflow.com, last release September 2026 (13.0.2), Android, iOS, Windows and web (no macOS, no Linux), 160/160 points, 155 open issues and PRs but a commit last week, depends on its own platform packages and `meta`, MIT.
- **url_launcher**: verified publisher flutter.dev, last release October 2026 (6.3.3), all six platforms, 160/160 points, same flutter/packages repo, depends only on its own platform packages, BSD-3-Clause.

`flutter pub add` wrote carets: `shared_preferences: ^2.5.5`, `flutter_secure_storage: ^11.2.0`, `path_provider: ^2.1.6`, `image_picker: ^1.2.3`, `permission_handler: ^13.0.2`, `url_launcher: ^6.3.2`. pubspec.lock resolved `http` to exactly `1.6.0`.

`^1.2.0` means `>=1.2.0 <2.0.0`: it accepts 1.2.1, 1.6.0, 1.99.0 and refuses 1.1.9 and 2.0.0, because a major version is allowed to break the API. pubspec.lock is committed for an app so that every machine and the CI build with exactly the same versions, not whatever was newest on the day of `pub get`.

`flutter pub outdated`: `shared_preferences` is 2.5.5, latest is 2.5.6, but 2.5.6 needs Flutter >=3.41.0 and Dart ^3.11.0, and I have Flutter 3.38.5. Same reason for `image_picker` 1.2.4 and `url_launcher` 6.3.3.

Breaking it: `http: 1.2.0` without the caret did not even resolve: `permission_handler ^13.0.2 is incompatible with http >=1.1.2 <1.2.1` (they need different versions of `web`). With `http: 1.5.0` the lock pinned exactly 1.5.0 and `pub outdated` showed 1.6.0 as resolvable but not upgradable. Caret put back, lock is 1.6.0 again.

## Level 2: A setting that persists

Dark mode, the city filter and the avatar path are read from `SharedPreferencesAsync` in `main()` before `runApp`, every read has a default or stays nullable. `setDark` calls `notifyListeners()` first and writes to disk after.

## Level 3: A token that persists safely

The token lives in `flutter_secure_storage` through `SecureStore`. `ApiClient` adds `Authorization: Bearer tok_…` by itself when there is a token and nothing when there is not. Sign out deletes it.

`prefs.setString('token', …)` would put the token in a plain file in the app folder: on Android `shared_prefs/FlutterSharedPreferences.xml`, on iOS a `.plist` in `Library/Preferences`. Anyone with a backup of the phone, a rooted / jailbroken phone, or a cable and a debug build can read it as plain text.

Platform surprises:
- iOS: Keychain items are not deleted when the app is uninstalled, so after a reinstall the old token can still be there. Clear it on the first launch if that matters.
- Android: the Keystore keys can be invalidated when the user removes the lock screen (or changes it), so the stored values cannot be decrypted any more and the read fails or returns nothing. The app has to treat that as "signed out".

## Level 4: The offline list

`UsersCache` writes `users.json` into `getApplicationDocumentsDirectory()`. `getAll()` saves after every good answer, returns the saved list with `fromCache: true` on `NoConnectionException`, and rethrows when there is no file, so a fresh install offline shows the Offline screen, not an empty list. The banner "Saved data · no connection" with Retry shows only when `fromCache` is true.

## Level 5: A photo and a No

Android: TODO check on the emulator (Take photo, Don't allow, twice, then the third tap should show my dialog with no system dialog, and "Open settings" should open the app's permission page).

iOS asks only once. The first No is already `permanentlyDenied`, every later tap goes straight to my dialog. The fourth Photos state is `limited` (the user picked only some photos).

`launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme: TODO. With `https://`: TODO.
