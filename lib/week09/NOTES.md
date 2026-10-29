# Week 9: Put It High, Subscribe Low

Run it with:

```
flutter run -t lib/week09/main.dart
```

## Level 1: Lift it up

The designer wanted the total price in the badge too. Passing `total` from `Shell` down to the badge touched 2 constructors (`BooksScreen` and `CartBadge`) in 3 files: `main.dart` (Shell computes and passes it), `books_screen.dart` (takes it only to pass it on) and `cart_badge.dart` (shows it). `BooksScreen` does not use the total at all, it only carries it.

One tap on Add printed 7 lines: `BooksScreen build` and all 6 `row ...` lines. `setState` in `Shell` rebuilds everything under it, so one tap rebuilt the whole screen and every row.
