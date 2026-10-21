import 'package:flutter/material.dart';

import '../../models/models.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _groupKey = GlobalKey<FormFieldState<String>>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final group = value ?? '';
    if (group.isEmpty || RegExp(r'^[A-Z]{2,4}-\d{4}$').hasMatch(group)) {
      return null;
    }
    return 'Format: IT-2302';
  }

  void _saveGroup(String value) {
    if (_groupKey.currentState?.validate() ?? false) {
      widget.onChanged(widget.profile.copyWith(group: value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    final lists = widget.events.where((e) => e.contains(name)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name'),
          textInputAction: TextInputAction.next,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onFieldSubmitted: (value) =>
              widget.onChanged(widget.profile.copyWith(name: value.trim())),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: _groupKey,
          controller: _group,
          decoration: const InputDecoration(labelText: 'Group'),
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onFieldSubmitted: _saveGroup,
        ),
        const SizedBox(height: 24),
        Text('You are on $lists lists'),
        const SizedBox(height: 24),
        const Text('Theme'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(mode.name),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
