import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  sport('Sport', Icons.sports_soccer),
  music('Music', Icons.music_note),
  art('Art', Icons.palette),
  career('Career', Icons.work);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.sport => scheme.tertiary,
    EventCategory.music => scheme.secondary,
    EventCategory.art => scheme.error,
    EventCategory.career => scheme.outline,
  };
}

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.location,
    required this.capacity,
    List<String> attendees = const [],
    this.online = false,
    this.description,
    this.favourite = false,
  }) : _attendees = attendees;

  factory Event.empty() => Event(
    id: '',
    title: '',
    category: EventCategory.tech,
    startsAt: DateTime.now(),
    location: '',
    capacity: 20,
  );

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final String location;
  final int capacity;
  final List<String> _attendees;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get attendees => List.unmodifiable(_attendees);
  int get count => _attendees.length;
  int get free => capacity - count;
  bool get isFull => free <= 0;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown get countdown {
    final left = startsAt.difference(DateTime.now());
    if (left > Duration.zero) return Upcoming(left);
    if (-left < const Duration(hours: 2)) return Started(-left);
    return const Ended();
  }

  Event copyWith({
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    String? location,
    int? capacity,
    List<String>? attendees,
    bool? online,
    String? description,
    bool? favourite,
  }) => Event(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    location: location ?? this.location,
    capacity: capacity ?? this.capacity,
    attendees: attendees ?? _attendees,
    online: online ?? this.online,
    description: description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}

class Profile {
  const Profile({required this.name, required this.group});

  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}

sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.ago);
  final Duration ago;
}

final class Ended extends Countdown {
  const Ended();
}
