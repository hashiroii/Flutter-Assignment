import 'dart:async';

import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'models.dart';
import 'routes.dart';
import 'utils/format.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event _event = widget.args.event;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _me => widget.args.profileName;

  void _apply(Event event) {
    widget.args.onChanged(event);
    setState(() => _event = event);
  }

  Future<bool> _confirm(String title, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _register() async {
    if (_me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () => widget.args.onTab(2),
          ),
        ),
      );
      return;
    }
    final ok = await _confirm('Register for ${_event.title}?', 'Register');
    if (!ok || !mounted) return;
    _apply(_event.copyWith(attendees: [..._event.attendees, _me]));
  }

  void _unregister() => _apply(
    _event.copyWith(
      attendees: _event.attendees.where((name) => name != _me).toList(),
    ),
  );

  Future<void> _edit() async {
    final event = await Navigator.of(
      context,
    ).pushNamed<Event>(Routes.form, arguments: FormArgs(_event));
    if (event == null || !mounted) return;
    _apply(event);
  }

  Future<void> _delete() async {
    final ok = await _confirm('Delete ${_event.title}?', 'Delete');
    if (!ok || !mounted) return;
    widget.args.onDelete(_event);
    Navigator.of(context).pop();
  }

  String _countdown(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'In ${formatDuration(left)}',
    Started() => 'Live now',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final registered = _event.contains(_me);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_event.title),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? _edit() : _delete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/event.png', fit: BoxFit.cover),
                  Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: _event.category.color(scheme),
                      child: Icon(
                        _event.category.icon,
                        size: 32,
                        color: scheme.surface,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Chip(label: Text(_event.category.label)),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Chip(label: Text(_countdown(_event.countdown))),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Attendees (${_event.count})'),
              ],
            ),
            Expanded(child: TabBarView(children: [_about(), _attendees()])),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: registered
                ? OutlinedButton(
                    onPressed: _unregister,
                    child: const Text('Cancel registration'),
                  )
                : FilledButton(
                    onPressed: _event.isFull ? null : _register,
                    child: Text(_event.isFull ? 'Full' : 'Register'),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _about() {
    final (:taken, :free) = _event.places;
    final description = _event.description;
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(_event.startsAt)),
        ),
        ListTile(
          leading: Icon(_event.online ? Icons.link : Icons.place),
          title: Text(_event.location),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: Text('$taken of ${_event.capacity} taken, $free free'),
        ),
        if (description != null)
          ListTile(leading: const Icon(Icons.notes), title: Text(description)),
      ],
    );
  }

  Widget _attendees() {
    if (_event.count == 0) {
      return const EmptyState(
        icon: Icons.person_off,
        message: 'Nobody has registered yet',
      );
    }
    return ListView(
      children: [
        for (final name in _event.attendees)
          ListTile(
            leading: CircleAvatar(child: Text(name[0])),
            title: Text(name == _me ? '$name (You)' : name),
            selected: name == _me,
          ),
      ],
    );
  }
}
