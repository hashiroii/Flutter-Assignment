import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (ok || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No app can open this')));
  }

  Future<void> _copyToken(BuildContext context) async {
    final token = await context.read<SecureStore>().readToken();
    await Clipboard.setData(ClipboardData(text: token ?? ''));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Token copied')));
  }

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.alternate_email),
            title: Text(user.email),
            subtitle: Text(user.username),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          if (website != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(website),
              onTap: () => _open(context, Uri.parse('https://$website')),
            ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text(
              '${a.city} ${a.zipcode}\n${a.geo.lat}, ${a.geo.lng}',
            ),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _copyToken(context),
                icon: const Icon(Icons.key),
                label: const Text('Copy token to clipboard'),
              ),
            ),
        ],
      ),
    );
  }
}
