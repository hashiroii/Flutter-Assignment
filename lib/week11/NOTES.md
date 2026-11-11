# Week 11: A Real Server

Run it with:

```
flutter run -t lib/week11/main.dart
```

## Level 1: Postman first

`GET https://jsonplaceholder.typicode.com/users` returns `200`, `Content-Type: application/json; charset=utf-8`, and a list of 10 users. `GET /users/1` returns one object with the same keys.

Nested once: `address`, `company`. Nested twice: `address.geo`. Every user has every key, nothing is null. `website` is the only one I treat as optional. `lat` and `lng` are strings, not numbers.

### User

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | yes (my choice) |
| company | object | ({String name, String catchPhrase}) | no |

### address

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object `{lat, lng}` | Geo | no |
| geo.lat | string ("-37.3159") | double (double.parse) | no |
| geo.lng | string ("81.1496") | double (double.parse) | no |

### company

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not stored | no |

### Statuses

- `GET /users/999` → `404`, body is `{}`. So 404 → `NotFoundException`.
- `POST /users` with `Content-Type: application/json` and `{"name":"Magzhan","username":"mag","email":"m@kbtu.kz"}` → `201`, the body is what I sent plus `"id": 11`. Nothing is really saved, the next GET still has 10 users.
- `GET /users?id=3` → a list with one user in it, not an object.

## Level 2: A model that survives

User 1 pasted into `main()` and decoded printed `User(1, Leanne Graham, Gwenborough)`. `User.fromJson(user.toJson()) == user` is true. `phoneDigits` for `1-770-736-8031 x56442` is `1770736803156442`.

With `json['lat'] as double`: `type 'String' is not a subtype of type 'double' in type cast`. With `"id": "1"`: `type 'String' is not a subtype of type 'int' in type cast`. Both name the field.

## Level 3: The repository

From `main()` before `runApp`: `getAll()` printed 10 names, `getById(999)` printed `not found`, `create(...)` printed `11`.

Without the 404 line in `_check`, `getById(999)` decoded `{}` and threw `BadResponseException: users/999: type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast` (on `company`, the first thing `fromJson` reads). It is my exception but the reason is wrong, the user does not exist, the JSON is fine.

`grep -rn "package:http" lib/` lists `core/api/api_client.dart` and `main.dart`. `main.dart` is the composition root and says `http.Client()`. The repository only talks to `ApiClient` (it gets back decoded JSON), so it does not import http at all.

## Level 4: The chain

Without the `BadResponseException()` arm the switch does not compile: `The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'`.

Host typo `jsonplaceholder.typicode.co`: `NoConnectionException` after 387 ms. Fixed host, Retry: TODO.

## Level 5: Two kinds of no network

| Test | Offline view after |
| --- | --- |
| Airplane mode | TODO |
| Hotspot with no internet | TODO |

Save is disabled while the POST is in flight, a double tap sends one request.
