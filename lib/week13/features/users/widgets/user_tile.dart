import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(child: Text(user.name[0])),
    title: Text(user.name),
    subtitle: Text('${user.email} · ${user.address.city}'),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: user)),
    ),
  );
}
