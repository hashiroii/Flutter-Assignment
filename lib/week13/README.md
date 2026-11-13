# Week 13: Where Things Go

The users app from weeks 11 and 12, split feature-first with tests. Notes are in [NOTES.md](NOTES.md).

```
lib/week13/
  main.dart
  core/api/        api_client.dart, api_exception.dart
  core/storage/    secure_store.dart
  features/users/  user.dart, address.dart, geo.dart, user_repository.dart,
                   http_user_repository.dart, fake_user_repository.dart,
                   users_cache.dart, users_model.dart, users_screen.dart,
                   user_detail_screen.dart, new_user_screen.dart, widgets/
  features/auth/   auth_model.dart, login_screen.dart
  features/settings/ settings_model.dart, settings_screen.dart
  features/profile/  profile_screen.dart
test/week13/
  features/users/  user_test.dart, users_model_test.dart,
                   user_repository_test.dart, users_screen_test.dart
  fakes/           fake_user_repository.dart
  fixtures/        user1.dart
```

## Quality checklist

`dart format` is run on the week 13 folders only, the older weeks are left as they were submitted.

```
$ flutter analyze
Analyzing flutter-kbtu...
No issues found! (ran in 1.5s)

$ dart format --output=none --set-exit-if-changed lib/week13 test/week13
Formatted 40 files (0 changed) in 0.05 seconds.

$ flutter test test/week13
00:02 +10: All tests passed!

$ tool/check_layers.sh
```
