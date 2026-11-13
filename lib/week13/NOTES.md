# Week 13: Where Things Go

Run it with:

```
flutter run -t lib/week13/main.dart
flutter test test/week13
tool/check_layers.sh
```

The week 12 app was copied into `week13/` in the first commit, then every move is its own commit (`git log --oneline` from `week 13: start from the week 12 users app`).

## Level 1: Feature-first

`tool/check_layers.sh` checks `lib/week13` by default (the older weeks are left as they were submitted). On the finished tree it prints nothing.

To keep `package:http` out of `main.dart`, `ApiClient` now creates its own `http.Client` unless one is passed in (`ApiClient(store, client: MockClient(...))` in the tests).

Breaking it: `import 'package:http/http.dart' as http;` at the top of `users_screen.dart` still compiles and runs, only an unused-import warning, and the script printed `lib/week13/features/users/users_screen.dart`. The compiler does not care about layers, the script does.

`user.dart` was split into `geo.dart`, `address.dart`, `user.dart`, one class per file. There were no `utils.dart` or `helpers.dart` to remove.

## Level 2: Interfaces and fakes

`UserRepository` is an `abstract interface class`, `HttpUserRepository` and `FakeUserRepository` implement it. `UsersModel`, `AuthModel` and `SettingsModel` get everything through the constructor, and `main.dart` is the only place that builds them.

`grep -rn "HttpUserRepository(" lib/week13` prints two lines: the call in `main.dart` and the constructor declaration in `http_user_repository.dart`. The only place that calls it is `main.dart`.

Demo mode: swap the two `repo` lines in `main.dart` and import `fake_user_repository.dart`. The app shows two users right away with no network.

If `UsersModel` built its own repository (`final _repo = UserRepository(ApiClient(...))`), the first line of "NoConnection sets error" I could not write is the arrange step: there is no way to hand the model a repository that fails.

## Level 3: Tests

`flutter test test/week13` prints `+10: All tests passed!` in about 2 seconds, with no network, disk or clock:

- `user_test.dart`: user 1 parses, `"id": "1"` throws `TypeError`, `Geo.fromJson` with a number `lat` throws `TypeError`
- `users_model_test.dart`: items from the fake, NoConnection sets error
- `user_repository_test.dart` (MockClient): 404 → `NotFoundException`, 500 → `ServerException(500)`, `SocketException` → `NoConnectionException`, number `lat` → `BadResponseException`
- `users_screen_test.dart`: the offline view and Retry

Breaking it: with an empty `catch (e) {}` in `UsersModel.load`, "NoConnection sets error" went red:

```
Expected: <Instance of 'NoConnectionException'>
  Actual: <null>
   Which: is not an instance of 'NoConnectionException'

test/week13/features/users/users_model_test.dart 24:7  main.<fn>.<fn>
```

## Level 4: Extract widgets

`UsersScreen.build` is now about 30 lines. Out of it came `UsersHeader`, `CityFilterBar`, `EmptyView`, `UsersErrorView`, `UsersDataView`, `UserTile`, `UserList`, `OfflineBanner` and the state views, all in `features/users/widgets/`. `SaveButton` came out of `NewUserScreen`, which was 61 lines. No `build()` is over 60 lines now.

A widget instead of a `_buildHeader()` method: a widget can be `const` and skipped on rebuild, has its own element so it rebuilds alone, shows up by name in DevTools and can be pumped in a test. A method is just more lines in the parent's `build`.

Breaking it: with the label changed to "Try again" the widget test fails at the tap: `The finder "Found 0 widgets with text "Retry": []" (used in a call to "tap()") could not find any matching widgets.`

Track widget rebuilds in DevTools: TODO.

## Level 5: The trace

Planted in `FakeUserRepository.getAll`: user 3 (Clementine Bauch) from the real JSON with `"lat": -68.6102`, a number instead of a string.

```
type 'double' is not a subtype of type 'String' in type cast
#0      new Geo.fromJson (package:kbtu_flutter/week13/features/users/geo.dart:5:35)
#1      new Address.fromJson (package:kbtu_flutter/week13/features/users/address.dart:17:14)
#2      new User.fromJson (package:kbtu_flutter/week13/features/users/user.dart:24:24)
#3      FakeUserRepository.getAll (package:kbtu_flutter/week13/features/users/fake_user_repository.dart:59:26)
<asynchronous suspension>
#4      UsersModel.load (package:kbtu_flutter/week13/features/users/users_model.dart:22:22)
<asynchronous suspension>
```

- The message: `type 'double' is not a subtype of type 'String' in type cast`, a number came where a string was promised.
- My first frame: `#0 geo.dart:5:35`, line 5 column 35 is `json['lat'] as String` inside `double.parse(...)`.
- The path: `Geo.fromJson` ← `Address.fromJson` ← `User.fromJson` ← `FakeUserRepository.getAll`, then `<asynchronous suspension>` and `UsersModel.load` line 22, the `await _repo.getAll()`. The model only catches `ApiException`, so a `TypeError` went straight through.
- The data: `address.geo.lat` of user 3.

`#0` is the right place to throw because that is where the claim "lat is a String" is made, and it fails loudly with the field. It is the wrong place to fix because `Geo` cannot know what to tell the user. The repository can: `HttpUserRepository` turns the `TypeError` into `BadResponseException('users: ...')`, and the screen shows the generic error instead of crashing. Both are in tests (`user_test.dart` and `user_repository_test.dart`). The plant was removed from the fake after that.
