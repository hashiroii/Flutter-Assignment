import 'package:flutter/material.dart';

import 'message_view.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.wifi_off,
    text: 'No connection',
    detail: 'Check the internet and try again.',
    onRetry: onRetry,
  );
}
