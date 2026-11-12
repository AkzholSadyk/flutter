import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/format.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.initial});
  final Event? initial;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _limit;
  late final FocusNode _titleFocus;
  late final FocusNode _locationFocus;
  late final FocusNode _limitFocus;
  late EventCategory _category;
  late DateTime _date;
  late TimeOfDay _time;
  late bool _online;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final event = widget.initial ?? Event.empty();
    _title = TextEditingController(text: event.title);
    _location = TextEditingController(text: event.location);
    _description = TextEditingController(text: event.description ?? '');
    _limit = TextEditingController(text: '${event.limit}');
    _titleFocus = FocusNode();
    _locationFocus = FocusNode();
    _limitFocus = FocusNode();
    _category = event.category;
    _date = DateTime(event.when.year, event.when.month, event.when.day);
    _time = TimeOfDay.fromDateTime(event.when);
    _online = event.isOnline;
    for (final controller in [_title, _location, _description, _limit]) {
      controller.addListener(() {
        if (mounted) setState(() => _dirty = true);
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _limit.dispose();
    _titleFocus.dispose();
    _locationFocus.dispose();
    _limitFocus.dispose();
    super.dispose();
  }

  DateTime get _combined =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
  bool get _isNew => widget.initial == null;

  Future<bool> _confirmDiscard() async {
    if (!_dirty || _saving) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (!mounted || value == null) return;
    setState(() {
      _date = value;
      _dirty = true;
    });
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (!mounted || value == null) return;
    setState(() {
      _time = value;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_isNew && !_combined.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future date and time.')),
      );
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final old = widget.initial;
    final event = Event(
      id: old?.id ?? '',
      title: _title.text.trim(),
      category: _category,
      when: _combined,
      location: _location.text.trim(),
      limit: int.parse(_limit.text),
      attendees: old?.attendees ?? const [],
      isOnline: _online,
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      isFavourite: old?.isFavourite ?? false,
    );
    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmDiscard() && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        body: Form(
          key: _key,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  return text.length < 3 || text.length > 60
                      ? 'Title must be 3–60 characters.'
                      : null;
                },
                onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                focusNode: _locationFocus,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: _online ? 'Online link' : 'Place',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Place is required.';
                  if (_online && !text.contains('://')) {
                    return 'Enter a link containing ://.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: EventCategory.values.map((category) {
                  return DropdownMenuItem<EventCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon),
                        const SizedBox(width: 8),
                        Text(category.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                      _dirty = true;
                    });
                  }
                },
                validator: (value) =>
                    value == null ? 'Choose a category.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limit,
                focusNode: _limitFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Capacity (1–500)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  if (number == null || number < 1 || number > 500) {
                    return 'Enter a whole number from 1 to 500.';
                  }
                  if (number < (widget.initial?.count ?? 0)) {
                    return 'Capacity cannot be below current attendees.';
                  }
                  return null;
                },
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text('Date: ${_date.day}/${_date.month}/${_date.year}'),
              ),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text('Time: ${_time.format(context)}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save event'),
              ),
              if (widget.initial != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Current date: ${formatDateTime(widget.initial!.when)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
