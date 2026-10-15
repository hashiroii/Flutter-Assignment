import 'package:flutter/material.dart';

import 'events_tab.dart';
import 'favourites_tab.dart';
import 'models.dart';
import 'profile_tab.dart';
import 'routes.dart';
import 'seed.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Event> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _save(Event event) => setState(
    () => _events = _events.any((e) => e.id == event.id)
        ? [for (final e in _events) e.id == event.id ? event : e]
        : [..._events, event],
  );

  void _delete(Event event) =>
      setState(() => _events = _events.where((e) => e.id != event.id).toList());

  void _toggleFavourite(Event event) =>
      _save(event.copyWith(favourite: !event.favourite));

  void _goTo(int tab) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = tab);
  }

  void _open(Event event) => Navigator.of(context).pushNamed(
    Routes.detail,
    arguments: DetailArgs(
      event: event,
      profileName: _profile.name,
      onChanged: _save,
      onDelete: _delete,
      onTab: _goTo,
    ),
  );

  Future<void> _add() async {
    final event = await Navigator.of(
      context,
    ).pushNamed<Event>(Routes.form, arguments: const FormArgs(null));
    if (event == null || !mounted) return;
    setState(() => _events = [..._events, event]);
  }

  void _about() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campus Events'),
        content: const Text('Lab 1. Browse and register for campus events.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.of(context).pop();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text('Events go back to the seed, profile is cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _events = seedEvents();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      EventsTab(events: _events, onOpen: _open, onFavourite: _toggleFavourite),
      FavouritesTab(
        events: _events,
        onOpen: _open,
        onFavourite: _toggleFavourite,
        onBrowse: () => _goTo(0),
      ),
      ProfileTab(
        profile: _profile,
        events: _events,
        themeMode: widget.themeMode,
        onChanged: (profile) => setState(() => _profile = profile),
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(['Events', 'Favourites', 'Profile'][_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Campus Events')),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _about,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset data'),
              onTap: _reset,
            ),
          ],
        ),
      ),
      body: tabs[_tab],
      floatingActionButton: _tab == 0
          ? FloatingActionButton(onPressed: _add, child: const Icon(Icons.add))
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) => setState(() => _tab = tab),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
