import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'form_screen.dart';
import 'models.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onTab,
  });

  final Event event;
  final String profileName;
  final ValueChanged<Event> onChanged;
  final ValueChanged<Event> onDelete;
  final ValueChanged<int> onTab;
}

class FormArgs {
  const FormArgs(this.event);

  final Event? event;
}

Route<dynamic>? generateRoute(RouteSettings settings) =>
    switch (settings.name) {
      Routes.detail => MaterialPageRoute(
        builder: (_) => DetailScreen(args: settings.arguments as DetailArgs),
      ),
      Routes.form => MaterialPageRoute<Event>(
        builder: (_) =>
            FormScreen(event: (settings.arguments as FormArgs).event),
      ),
      _ => null,
    };

Route<dynamic> unknownRoute(RouteSettings settings) => MaterialPageRoute(
  builder: (_) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const Center(child: Text('Not found')),
  ),
);
