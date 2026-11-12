# Campus Events

A Flutter Material 3 app for discovering and registering for campus events. All state is in memory; restarting the app restores seed data.

## Run

```bash
flutter pub get
dart format .
flutter analyze
flutter run
```

## Domain

An event has a title, category, date/time, location or online link, capacity, attendee names, optional description, and favourite flag. The profile stores a name and group.

## Screenshots

Add these three screenshots before submission:
- `screenshots/phone-light.png`
- `screenshots/phone-dark.png`
- `screenshots/tablet-grid.png`

## Decisions

The event list and profile are owned by the shell so tab changes can be shared without a database. Event detail is pushed on the Navigator stack so it covers the navigation bar, while the form returns an `Event` from `Navigator.pop` so cancelling leaves the list unchanged. The list uses `LayoutBuilder` because the available width, not the device model, determines whether a grid is appropriate. The form's dirty flag tracks edits and lets `PopScope` ask before discarding them. Counts such as free places are getters derived from the attendee list and capacity to avoid duplicated state. The seed data is generated relative to the current date so the past/upcoming examples remain meaningful. With week 9 tools, I would replace in-memory state with a repository and persistence layer and add automated tests.
