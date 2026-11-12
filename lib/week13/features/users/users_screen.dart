import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/loading_view.dart';
import 'widgets/users_data_view.dart';
import 'widgets/users_error_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final error = m.error;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
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
          : error == null
          ? const UsersDataView()
          : UsersErrorView(error: error, onRetry: m.load),
    );
  }
}
