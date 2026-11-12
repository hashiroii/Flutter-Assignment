import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/generic_error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/message_view.dart';
import 'widgets/offline_banner.dart';
import 'widgets/offline_view.dart';
import 'widgets/server_error_view.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);
    final users = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(city ?? 'Users'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        child: const Icon(Icons.person_add),
      ),
      body: m.loading
          ? const LoadingView()
          : switch (m.error) {
              null => Column(
                children: [
                  if (m.fromCache) OfflineBanner(onRetry: m.load),
                  Expanded(child: UserList(users, onRefresh: m.load)),
                ],
              ),
              NoConnectionException() => OfflineView(onRetry: m.load),
              NotFoundException() ||
              UnauthorizedException() => const MessageView(
                icon: Icons.block,
                text: 'This list is not available.',
              ),
              ServerException(:final status) => ServerErrorView(
                status,
                onRetry: m.load,
              ),
              BadResponseException() => const GenericErrorView(),
            },
    );
  }
}
