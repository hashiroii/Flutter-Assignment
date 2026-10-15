import 'package:flutter/material.dart';

import 'models.dart';
import 'utils/format.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.event});

  final Event? event;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Event _initial = widget.event ?? Event.empty();
  late final bool _isNew = widget.event == null;

  late final _title = TextEditingController(text: _initial.title);
  late final _location = TextEditingController(text: _initial.location);
  late final _capacity = TextEditingController(text: '${_initial.capacity}');
  late final _description = TextEditingController(
    text: _initial.description ?? '',
  );
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();

  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late EventCategory? _category = widget.event?.category;
  late bool _online = _initial.online;
  DateTime? _date;
  TimeOfDay? _time;
  DateTime? _initialDate;
  TimeOfDay? _initialTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final startsAt = widget.event?.startsAt;
    if (startsAt != null) {
      _initialDate = DateTime(startsAt.year, startsAt.month, startsAt.day);
      _initialTime = TimeOfDay.fromDateTime(startsAt);
      _setDate(_initialDate);
      _setTime(_initialTime);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _capacity.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _locationFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _title.text != _initial.title ||
      _location.text != _initial.location ||
      _capacity.text != '${_initial.capacity}' ||
      _description.text != (_initial.description ?? '') ||
      _category != widget.event?.category ||
      _online != _initial.online ||
      _date != _initialDate ||
      _time != _initialTime;

  void _setDate(DateTime? date) {
    _date = date;
    _dateText.text = date == null ? '' : formatDate(date);
  }

  void _setTime(TimeOfDay? time) {
    _time = time;
    _timeText.text = time == null
        ? ''
        : formatHourMinute(time.hour, time.minute);
  }

  DateTime? get _startsAt {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    setState(() => _setDate(picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _setTime(picked));
  }

  String? _validateTitle(String? value) {
    final length = (value ?? '').trim().length;
    if (length < 3 || length > 60) return 'From 3 to 60 characters';
    return null;
  }

  String? _validateLocation(String? value) {
    final location = (value ?? '').trim();
    if (location.isEmpty) return 'Required';
    if (_online && !location.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateCapacity(String? value) {
    final capacity = int.tryParse(value ?? '');
    if (capacity == null || capacity < 1 || capacity > 500) {
      return 'A number from 1 to 500';
    }
    if (capacity < _initial.count) {
      return '${_initial.count} people are already registered';
    }
    return null;
  }

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    final startsAt = _startsAt;
    if (_time == null) return 'Pick a time';
    if (_isNew && startsAt != null && startsAt.isBefore(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    final startsAt = _startsAt;
    final category = _category;
    if (_saving || !valid || startsAt == null || category == null) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final description = _description.text.trim();
    Navigator.of(context).pop(
      Event(
        id: _isNew ? '${DateTime.now().microsecondsSinceEpoch}' : _initial.id,
        title: _title.text.trim(),
        category: category,
        startsAt: startsAt,
        location: _location.text.trim(),
        capacity: int.parse(_capacity.text),
        attendees: _initial.attendees,
        online: _online,
        description: description.isEmpty ? null : description,
        favourite: _initial.favourite,
      ),
    );
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _confirmDiscard();
    },
    child: Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              focusNode: _titleFocus,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 60,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              onFieldSubmitted: (_) => _locationFocus.requestFocus(),
              validator: _validateTitle,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in EventCategory.values)
                  DropdownMenuItem(
                    value: c,
                    child: Row(
                      spacing: 8,
                      children: [Icon(c.icon), Text(c.label)],
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _category = value),
              validator: (value) => value == null ? 'Pick a category' : null,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Online'),
              value: _online,
              onChanged: (value) => setState(() => _online = value),
            ),
            TextFormField(
              controller: _location,
              focusNode: _locationFocus,
              decoration: InputDecoration(
                labelText: _online ? 'Link' : 'Location',
              ),
              keyboardType: _online ? TextInputType.url : TextInputType.text,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
              validator: _validateLocation,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _capacity,
              focusNode: _capacityFocus,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
              validator: _validateCapacity,
            ),
            const SizedBox(height: 12),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateText,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Date'),
                    onTap: _pickDate,
                    validator: _validateDate,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _timeText,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Time'),
                    onTap: _pickTime,
                    validator: _validateTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              focusNode: _descriptionFocus,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.done,
              onTapOutside: _unfocus,
              validator: (_) => null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
