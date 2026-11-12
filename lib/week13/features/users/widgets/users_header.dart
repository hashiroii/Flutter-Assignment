import 'package:flutter/material.dart';

class UsersHeader extends StatelessWidget {
  const UsersHeader({super.key, required this.shown, required this.total});

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      shown == total ? '$total users' : '$shown of $total users',
      style: Theme.of(context).textTheme.titleSmall,
    ),
  );
}
