# Week 9: Put It High, Subscribe Low

Run it with:

```
flutter run -t lib/week09/main.dart
```

## Level 1: Lift it up

The designer wanted the total price in the badge too. Passing `total` from `Shell` down to the badge touched 2 constructors (`BooksScreen` and `CartBadge`) in 3 files: `main.dart` (Shell computes and passes it), `books_screen.dart` (takes it only to pass it on) and `cart_badge.dart` (shows it). `BooksScreen` does not use the total at all, it only carries it.

One tap on Add printed 7 lines: `BooksScreen build` and all 6 `row ...` lines. `setState` in `Shell` rebuilds everything under it, so one tap rebuilt the whole screen and every row.

## Level 2: A model with no widgets

Before `runApp`, adding two books, adding the first one again and removing it printed `1 items, 3100 ₸`. `cart.items.add(books[0])` threw `Unsupported operation: Cannot add to an unmodifiable list`.

## Level 3: Provider errors

The loud one, `context.watch<Cart>().add(b)` in the Add button:

```
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);
```

The silent one, `context.read<Cart>().count` in the badge: no error, no warning. The app runs, but after Add the badge still says 0, because the badge never subscribed to the cart.

With provider the total in the badge would take one line in `CartBadge` and no constructors. The final badge shows only the count, so changing a quantity does not rebuild it.

## Level 4: Rebuilds

Three presses on + in a cart row:

| Badge uses | `badge build` lines |
| --- | --- |
| `context.watch<Cart>().count` | 3 |
| `context.select<Cart, int>((c) => c.count)` | 0 |

With `select`, removing a book printed `badge build` once. With `context.watch<Cart>()` moved up into `BooksScreen.build`, the same three presses rebuilt all 6 rows each time (18 row lines), and that screen was not even visible. The rows use `select` on their own book, so normally only the row whose book changed rebuilds.

## Where does it live?

- The cart: provided. Both screens and the badge need it, so it sits above `MaterialApp`.
- The search text in the Books AppBar: ephemeral. Only `BooksScreen` uses it, so it is a field in its `State`.
- Whether the Cart screen's total is expanded or collapsed: ephemeral. It is only how one widget looks, and nobody else cares.
- The theme mode for a dark-mode switch: provided. `MaterialApp` reads it at the top, and a settings switch somewhere below changes it.
