import 'package:flutter/material.dart';
import 'models/event.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs(
      {required this.event, required this.onChanged, required this.onDeleted});
  final Event event;
  final ValueChanged<Event> onChanged;
  final ValueChanged<String> onDeleted;
}

class FormArgs {
  const FormArgs({this.event});
  final Event? event;
}
