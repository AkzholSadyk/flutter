import 'dart:async';
import 'package:flutter/material.dart';
import 'data/seed.dart';
import 'models/event.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/home_shell.dart';

void main() => runApp(const CampusEventsApp());

class CampusEventsApp extends StatefulWidget {
  const CampusEventsApp({super.key});
  @override
  State<CampusEventsApp> createState() => _CampusEventsAppState();
}

class _CampusEventsAppState extends State<CampusEventsApp> {
  ThemeMode _themeMode = ThemeMode.system;
  void setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF315DA8));
    return MaterialApp(
      title: 'Campus Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9BB8FF), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) =>
            HomeShell(themeMode: _themeMode, onThemeChanged: setThemeMode)
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.detail &&
            settings.arguments is DetailArgs) {
          return MaterialPageRoute(
              builder: (_) =>
                  EventDetailScreen(args: settings.arguments as DetailArgs));
        }
        if (settings.name == Routes.form && settings.arguments is FormArgs) {
          return MaterialPageRoute<Event>(
              builder: (_) => EventFormScreen(
                  initial: (settings.arguments as FormArgs).event));
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
      ),
    );
  }
}
