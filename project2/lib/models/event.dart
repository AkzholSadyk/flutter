import 'package:flutter/material.dart';

enum EventCategory {
  tech('Technology', Icons.computer),
  music('Music', Icons.music_note),
  sport('Sport', Icons.sports_basketball),
  art('Arts', Icons.palette),
  career('Career', Icons.work),
  social('Social', Icons.groups);

  const EventCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
        EventCategory.tech => scheme.primary,
        EventCategory.music => scheme.tertiary,
        EventCategory.sport => scheme.secondary,
        EventCategory.art => scheme.error,
        EventCategory.career => scheme.primaryContainer,
        EventCategory.social => scheme.secondaryContainer,
      };
}

class Event {
  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.location,
    required this.limit,
    List<String> attendees = const [],
    this.isOnline = false,
    this.description,
    this.isFavourite = false,
  }) : attendees = List.unmodifiable(attendees);

  Event.empty()
      : id = '',
        title = '',
        category = EventCategory.tech,
        when = DateTime.now().add(const Duration(days: 1)),
        location = '',
        limit = 20,
        attendees = const [],
        isOnline = false,
        description = null,
        isFavourite = false;

  final String id;
  final String title;
  final EventCategory category;
  final DateTime when;
  final String location;
  final int limit;
  final List<String> attendees;
  final bool isOnline;
  final String? description;
  final bool isFavourite;

  int get count => attendees.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => attendees.contains(name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? when,
    String? location,
    int? limit,
    List<String>? attendees,
    bool? isOnline,
    Object? description = _unset,
    bool? isFavourite,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        when: when ?? this.when,
        location: location ?? this.location,
        limit: limit ?? this.limit,
        attendees: attendees ?? this.attendees,
        isOnline: isOnline ?? this.isOnline,
        description: identical(description, _unset)
            ? this.description
            : description as String?,
        isFavourite: isFavourite ?? this.isFavourite,
      );

  static const Object _unset = Object();
}

sealed class Countdown {
  const Countdown();
  const factory Countdown.upcoming(Duration duration) = Upcoming;
  const factory Countdown.started(Duration duration) = Started;
  const factory Countdown.ended() = Ended;

  factory Countdown.from(DateTime date, DateTime now) {
    final difference = date.difference(now);
    if (difference.isNegative) return const Countdown.ended();
    if (difference == Duration.zero)
      return const Countdown.started(Duration.zero);
    return Countdown.upcoming(difference);
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.duration);
  final Duration duration;
}

final class Started extends Countdown {
  const Started(this.duration);
  final Duration duration;
}

final class Ended extends Countdown {
  const Ended();
}

class Profile {
  const Profile({required this.name, required this.group});
  const Profile.empty()
      : name = '',
        group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
