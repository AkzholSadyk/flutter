import 'package:flutter/material.dart';
import '../data/seed.dart';
import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';
import 'detail_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell(
      {super.key, required this.themeMode, required this.onThemeChanged});
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late List<Event> _events;
  Profile _profile = const Profile.empty();
  int _tab = 0;
  @override
  void initState() {
    super.initState();
    _events = seedEvents();
  }

  void _update(Event changed) => setState(() {
        final index = _events.indexWhere((e) => e.id == changed.id);
        if (index < 0) {
          _events = [..._events, changed];
        } else {
          _events = [..._events]..[index] = changed;
        }
      });
  void _openForm([Event? event]) async {
    final result = await Navigator.pushNamed<Event>(context, Routes.form,
        arguments: FormArgs(event: event));
    if (!mounted || result == null) return;
    if (event == null) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      _update(result.copyWith(id: id));
    } else {
      _update(result.copyWith(id: event.id));
    }
  }

  void _openDetail(Event event) {
    Navigator.pushNamed(context, Routes.detail,
        arguments: DetailArgs(
          event: event,
          onChanged: _update,
          onDeleted: (id) => setState(
              () => _events = _events.where((e) => e.id != id).toList()),
        ));
  }

  void _reset() async {
    Navigator.pop(context);
    final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Reset data?'),
              content: const Text(
                  'Restore the original events and clear the profile?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Reset'))
              ],
            ));
    if (!mounted || yes != true) return;
    setState(() {
      _events = seedEvents();
      _profile = const Profile.empty();
      _tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favourites = _events.where((e) => e.isFavourite).length;
    return Scaffold(
      appBar: AppBar(
          title: Text(['Campus Events', 'Favourites', 'Profile'][_tab]),
          actions: [
            if (_tab == 0)
              IconButton(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  tooltip: 'Add event'),
          ]),
      drawer: Drawer(
          child: SafeArea(
              child: Column(children: [
        const ListTile(
            leading: Icon(Icons.school),
            title: Text('Campus Events'),
            subtitle: Text('Student community')),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                          title: const Text('About Campus Events'),
                          content: const Text(
                              'A Flutter lab app for campus event discovery and registration.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'))
                          ]));
            }),
        ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset data'),
            onTap: _reset),
      ]))),
      body: IndexedStack(index: _tab, children: [
        EventListTab(
            events: _events,
            onOpen: _openDetail,
            onFavourite: (e) =>
                _update(e.copyWith(isFavourite: !e.isFavourite))),
        FavouriteTab(
            events: _events.where((e) => e.isFavourite).toList(),
            onOpen: _openDetail),
        ProfileTab(
            profile: _profile,
            events: _events,
            themeMode: widget.themeMode,
            onProfileChanged: (p) => setState(() => _profile = p),
            onThemeChanged: widget.onThemeChanged),
      ]),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('New event'))
          : null,
      bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.event), label: 'Events'),
            NavigationDestination(
                icon: Badge(
                    isLabelVisible: favourites > 0,
                    label: Text('$favourites'),
                    child: const Icon(Icons.favorite)),
                label: 'Favourites'),
            const NavigationDestination(
                icon: Icon(Icons.person), label: 'Profile'),
          ]),
    );
  }
}

class EventListTab extends StatefulWidget {
  const EventListTab(
      {super.key,
      required this.events,
      required this.onOpen,
      required this.onFavourite});
  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;
  @override
  State<EventListTab> createState() => _EventListTabState();
}

class _EventListTabState extends State<EventListTab> {
  String _search = '';
  EventCategory? _category;
  bool _pastOnly = false;
  @override
  Widget build(BuildContext context) {
    final filtered = widget.events.where((e) {
      final matches = e.title.toLowerCase().contains(_search.toLowerCase()) ||
          e.location.toLowerCase().contains(_search.toLowerCase());
      return matches &&
          (_category == null || e.category == _category) &&
          (!_pastOnly || e.isPast);
    }).toList()
      ..sort((a, b) {
        if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
        return a.when.compareTo(b.when);
      });
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search title or place',
                border: const OutlineInputBorder(),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _search = ''))),
            onChanged: (v) => setState(() => _search = v),
          )),
      SizedBox(
          height: 48,
          child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        label: const Text('All'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null))),
                ...EventCategory.values.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        label: Text(c.label),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c)))),
              ])),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                  label: const Text('Past events'),
                  selected: _pastOnly,
                  onSelected: (v) => setState(() => _pastOnly = v)))),
      Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy,
                  message: 'No events match your filters.',
                  buttonLabel: 'Clear filters',
                  onPressed: () => setState(() {
                        _search = '';
                        _category = null;
                        _pastOnly = false;
                      }))
              : LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth >= 600) {
                    final columns =
                        (constraints.maxWidth / 360).floor().clamp(1, 3);
                    return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio: 1.55,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => EventCard(
                            event: filtered[i],
                            onTap: () => widget.onOpen(filtered[i]),
                            onFavourite: () =>
                                widget.onFavourite(filtered[i])));
                  }
                  return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => EventCard(
                          event: filtered[i],
                          onTap: () => widget.onOpen(filtered[i]),
                          onFavourite: () => widget.onFavourite(filtered[i])));
                })),
    ]);
  }
}

class EventCard extends StatelessWidget {
  const EventCard(
      {super.key,
      required this.event,
      required this.onTap,
      required this.onFavourite});
  final Event event;
  final VoidCallback onTap, onFavourite;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final places = event.places;
    return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Stack(clipBehavior: Clip.none, children: [
                    CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            event.category.color(colors).withValues(alpha: .15),
                        child: Icon(event.category.icon,
                            color: event.category.color(colors))),
                    if (event.isFull)
                      Positioned(
                          right: -12,
                          bottom: -6,
                          child: _StatusBadge(text: 'FULL'))
                    else if (places.free <= 5)
                      Positioned(
                          right: -14,
                          bottom: -6,
                          child: _StatusBadge(text: '${places.free} left')),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Text(event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(formatDateTime(event.when),
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall),
                      ])),
                  IconButton(
                      onPressed: onFavourite,
                      icon: Icon(
                          event.isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: event.isFavourite ? colors.error : null)),
                ]))));
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Text(text, style: Theme.of(context).textTheme.labelSmall)));
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.message,
      this.buttonLabel,
      this.onPressed});
  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 48, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onPressed, child: Text(buttonLabel!))
            ],
          ])));
}

class FavouriteTab extends StatelessWidget {
  const FavouriteTab({super.key, required this.events, required this.onOpen});
  final List<Event> events;
  final ValueChanged<Event> onOpen;
  @override
  Widget build(BuildContext context) => events.isEmpty
      ? const EmptyState(
          icon: Icons.favorite_border, message: 'No favourites yet.')
      : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => EventCard(
              event: events[i],
              onTap: () => onOpen(events[i]),
              onFavourite: () {}));
}

class ProfileTab extends StatefulWidget {
  const ProfileTab(
      {super.key,
      required this.profile,
      required this.events,
      required this.themeMode,
      required this.onProfileChanged,
      required this.onThemeChanged});
  final Profile profile;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _name;
  late final TextEditingController _group;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
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

  @override
  Widget build(BuildContext context) {
    final joined = widget.events
        .where((e) =>
            e.contains(widget.profile.name) && widget.profile.name.isNotEmpty)
        .length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
      const SizedBox(height: 16),
      TextField(
          controller: _name,
          decoration: const InputDecoration(
              labelText: 'Your name', border: OutlineInputBorder()),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => widget.onProfileChanged(
              widget.profile.copyWith(name: _name.text.trim()))),
      const SizedBox(height: 12),
      TextField(
          controller: _group,
          decoration: const InputDecoration(
              labelText: 'Group', border: OutlineInputBorder()),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onProfileChanged(widget.profile
              .copyWith(name: _name.text.trim(), group: _group.text.trim()))),
      const SizedBox(height: 12),
      FilledButton(
          onPressed: () => widget.onProfileChanged(
              Profile(name: _name.text.trim(), group: _group.text.trim())),
          child: const Text('Save profile')),
      const SizedBox(height: 8),
      Text('You are on $joined lists'),
      const SizedBox(height: 24),
      Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
      Wrap(spacing: 8, children: [
        ChoiceChip(
            label: const Text('System'),
            selected: widget.themeMode == ThemeMode.system,
            onSelected: (_) => widget.onThemeChanged(ThemeMode.system)),
        ChoiceChip(
            label: const Text('Light'),
            selected: widget.themeMode == ThemeMode.light,
            onSelected: (_) => widget.onThemeChanged(ThemeMode.light)),
        ChoiceChip(
            label: const Text('Dark'),
            selected: widget.themeMode == ThemeMode.dark,
            onSelected: (_) => widget.onThemeChanged(ThemeMode.dark)),
      ]),
    ]);
  }
}
