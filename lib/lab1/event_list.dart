import 'package:flutter/material.dart';

import 'event_card.dart';
import 'models.dart';

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;

  Widget _card(int i) => EventCard(
    event: events[i],
    onTap: () => onOpen(events[i]),
    onFavourite: () => onFavourite(events[i]),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 600) {
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisExtent: 124,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: events.length,
          itemBuilder: (_, i) => _card(i),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _card(i),
      );
    },
  );
}
