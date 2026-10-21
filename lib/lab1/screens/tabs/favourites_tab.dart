import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/event_list.dart';
import '../../models/models.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = events.where((e) => e.favourite).toList();
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse events',
        onAction: onBrowse,
      );
    }
    return EventList(
      events: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
