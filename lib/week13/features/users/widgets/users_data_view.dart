import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../settings/settings_model.dart';
import '../users_model.dart';
import 'city_filter_bar.dart';
import 'empty_view.dart';
import 'offline_banner.dart';
import 'user_list.dart';
import 'users_header.dart';

class UsersDataView extends StatelessWidget {
  const UsersDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);
    final users = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (m.fromCache) OfflineBanner(onRetry: m.load),
        UsersHeader(shown: users.length, total: m.items.length),
        if (city != null)
          CityFilterBar(
            city: city,
            onClear: () => context.read<SettingsModel>().setCity(null),
          ),
        Expanded(
          child: users.isEmpty
              ? EmptyView(city: city)
              : UserList(users, onRefresh: m.load),
        ),
      ],
    );
  }
}
