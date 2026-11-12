
import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final yearText = _year.text.trim();

      final book = Book(
        title: _title.text.trim(),
        author: _author.text.trim(),
        pages: int.parse(_pages.text.trim()),
        year: int.tryParse(yearText),
      );

      Navigator.of(context).pop(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add book'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Book information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              // TITLE
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).nextFocus();
                },
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'Title must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // AUTHOR
              TextFormField(
                controller: _author,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).nextFocus();
                },
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter the author';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // PAGES
              TextFormField(
                controller: _pages,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Number of pages',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).nextFocus();
                },
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                validator: (value) {
                  final number = int.tryParse(value ?? '');

                  if (number == null || number <= 0) {
                    return 'A whole number above 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // YEAR (OPTIONAL)
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Publication year (optional)',
                  hintText: 'For example, 2023',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onFieldSubmitted: (_) => _save(),
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                validator: (value) {
                  final text = (value ?? '').trim();

                  if (text.isEmpty) {
                    return null;
                  }

                  final year = int.tryParse(text);

                  if (year == null ||
                      year < 1450 ||
                      year > DateTime.now().year) {
                    return 'Enter a year from 1450 to '
                        '${DateTime.now().year}';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
