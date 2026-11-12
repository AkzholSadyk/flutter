import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.args});
  final DetailArgs args;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.args.event;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormArgs(event: _event),
    );
    if (!mounted || result == null) return;
    final updated = result.copyWith(id: _event.id);
    setState(() => _event = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || yes != true) return;
    widget.args.onDeleted(_event.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _register() async {
    if (_event.isFull || _event.contains('You')) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register?'),
        content: Text('Join "${_event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (!mounted || yes != true) return;
    final updated = _event.copyWith(attendees: [..._event.attendees, 'You']);
    setState(() => _event = updated);
    widget.args.onChanged(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are registered.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    final countdown = Countdown.from(event.when, _now);
    final countdownText = switch (countdown) {
      Upcoming(:final duration) => 'Starts in ${formatCountdown(duration)}',
      Started(:final duration) => 'Started ${duration.inMinutes} min ago',
      Ended() => 'Event ended',
    };
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _edit();
              if (value == 'delete') _delete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/campus.png',
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Chip(
                  avatar: Icon(event.category.icon, size: 18),
                  label: Text(event.category.label),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Chip(label: Text(countdownText)),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Icon(event.category.icon,
                    size: 42, color: colors.onPrimary),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(formatDateTime(event.when)),
                Text(event.isOnline
                    ? 'Online: ${event.location}'
                    : event.location),
                const SizedBox(height: 12),
                Text(
                    '${event.count} attending · ${event.freePlaces} places left'),
                if (event.description != null) ...[
                  const SizedBox(height: 8),
                  Text(event.description!),
                ],
                const SizedBox(height: 16),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          const Tab(text: 'About'),
                          Tab(text: 'Names (${event.count})'),
                        ],
                      ),
                      SizedBox(
                        height: 180,
                        child: TabBarView(
                          children: [
                            ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                Text('Category: ${event.category.label}'),
                                Text('Location: ${event.location}'),
                                Text('Capacity: ${event.limit}'),
                                if (event.description != null)
                                  Text(event.description!),
                              ],
                            ),
                            ListView(
                              children: event.attendees
                                  .map(
                                    (name) => ListTile(
                                      title: Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: name == 'You'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      leading: Icon(
                                        name == 'You'
                                            ? Icons.person
                                            : Icons.circle_outlined,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed:
                      event.isFull || event.contains('You') ? null : _register,
                  icon: const Icon(Icons.how_to_reg),
                  label: Text(
                    event.isFull
                        ? 'Full'
                        : event.contains('You')
                            ? 'Registered'
                            : 'Register',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
