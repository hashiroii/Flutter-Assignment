# Week 10: The Data Arrives Later

Run it with:

```
flutter run -t lib/week10/main.dart
```

## Level 1: The order of events

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

| Expected | Actual |
| --- | --- |
| A | A |
| C | C |
| B | fetchStudents #1 |
| 6 students | (first frame of the app) |
| | B (2 s later) |
| | 6 students |

I forgot that `fetchStudents()` runs synchronously until its first `await`, so `fetchStudents #1` comes right after C. Nothing waited for the timer: `main()` finished, the app drew, and B and `6 students` came later as events.

Three calls in a row from `main()`: the third one printed `Unhandled Exception: Instance of 'NoConnectionException'` and the app kept running.

With `sleep(const Duration(seconds: 2))` instead of `await Future.delayed`, the app showed nothing for two seconds. The loop was blocked, not waiting.

## Level 2: Four states by hand

Loading for two seconds, then the list. Refresh, refresh again: the third fetch shows "Could not load students", Retry shows the list again (fetch #4). `FakeApi(empty: true)` shows "No students yet".

Back during the two seconds with the `mounted` guards: nothing in the console. Without them:

```
setState() called after dispose(): _StudentsScreenState#196cf(lifecycle state: defunct, not mounted)
```

## Level 3: FutureBuilder

Ten flips of the Switch: one `fetchStudents #1`, the list never flickers.

With `future: _api.fetchStudents()` inline in `build`, every flip printed a new `fetchStudents #2`, `#3`, ... and showed the spinner, and the third one failed.

With `hasData` checked before `hasError` and the server always failing, the screen shows the spinner forever.

## Level 4: Countdown

Version B, Back at 7, with `_sub.cancel()`: the console stops at `tick 7`.

Version B without `_sub.cancel()`: one second after Back, `setState() called after dispose(): _ListenCountdownState#f9bd2(lifecycle state: defunct, not mounted)`, and the console kept going `tick 6`, `tick 5` ... `tick 0` with an error every second and nobody on screen.

Version A, Back at 7, no `cancel()` anywhere in my code: the console stops at `tick 7`. StreamBuilder cancels the subscription for me.

## Level 5: Errors that do not vanish

The wrong version, `_api.save(n); Navigator.pop(context);`: `flutter analyze` says `Missing an 'await' for the 'Future' computed by this expression • unawaited_futures`. The second save popped the screen and the console said `Unhandled Exception: Bad state: server rejected 6`. The user saw a success.

The honest version awaits the save, pops only on success, and shows "server rejected 6" in a SnackBar when it fails. The button is disabled with a spinner while saving, so a fast double tap sends one request.

The by-hand screen keeps one `FakeApi` for every time it is opened (a static field), otherwise each open starts from call #1 and the second save never happens.
