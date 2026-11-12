import 'package:flutter/material.dart';

import 'message_view.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.city});

  final String? city;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.person_search,
    text: city == null ? 'No users yet' : 'No users in $city',
  );
}
