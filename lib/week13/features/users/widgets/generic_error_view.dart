import 'package:flutter/material.dart';

import 'message_view.dart';

class GenericErrorView extends StatelessWidget {
  const GenericErrorView({super.key});

  @override
  Widget build(BuildContext context) => const MessageView(
    icon: Icons.error_outline,
    text: 'Something went wrong while reading the data.',
  );
}
