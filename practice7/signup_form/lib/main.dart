import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  // Focus nodes
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // State
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _password,
      _confirm,
      _birthController,
    ]) {
      controller.dispose();
    }

    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    super.dispose();
  }

  // Level 1: SnackBar helper
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Level 4: Date picker
  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;
    if (!mounted) return;

    setState(() {
      _birth = picked;

      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();

      _birthController.text = '$day.$month.$year';
    });

    _formKey.currentState?.validate();
  }

  // Level 2: Form validation
  // Level 5: Show summary
  void _signUp() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      _showMessage('Account created');

      setState(() {
        _done = true;
      });
    }
  }

  // Level 5: Reset form
  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthController.clear();

      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
      _passwordLength = 0;
    });
  }

  // Level 5: Summary screen
  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.check_circle, color: Colors.teal, size: 70),
          const SizedBox(height: 12),
          const Text(
            'Account created!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          SummaryCard(
            name: _name.text.trim(),
            email: _email.text.trim(),
            group: _group ?? '',
            birthDate: _birthController.text,
          ),

          const SizedBox(height: 24),

          TextButton.icon(
            onPressed: _startOver,
            icon: const Icon(Icons.refresh),
            label: const Text('Start over'),
          ),
        ],
      ),
    );
  }

  // Levels 1-4: Form screen
  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // NAME
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onFieldSubmitted: (_) {
                _emailFocus.requestFocus();
              },
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              validator: (value) {
                if ((value ?? '').trim().length < 2) {
                  return 'Name is too short';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // EMAIL
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              onFieldSubmitted: (_) {
                _passwordFocus.requestFocus();
              },
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              validator: (value) {
                final email = (value ?? '').trim();
                final at = email.indexOf('@');

                if (at <= 0 ||
                    at == email.length - 1 ||
                    !email.substring(at + 1).contains('.')) {
                  return 'Email looks wrong';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // PASSWORD
            TextFormField(
              controller: _password,
              focusNode: _passwordFocus,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              onChanged: (value) {
                setState(() {
                  _passwordLength = value.length;
                });
              },
              onFieldSubmitted: (_) {
                _confirmFocus.requestFocus();
              },
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              validator: (value) {
                if ((value ?? '').length < 8) {
                  return 'Password is too short';
                }
                return null;
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_passwordLength of 8',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            // CONFIRM PASSWORD
            TextFormField(
              controller: _confirm,
              focusNode: _confirmFocus,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              onFieldSubmitted: (_) => _signUp(),
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              validator: (value) {
                if (value != _password.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // GROUP DROPDOWN
            DropdownButtonFormField<String>(
              key: ValueKey(_group),
              initialValue: _group,
              decoration: const InputDecoration(
                labelText: 'Group',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.groups),
              ),
              items: [
                for (final group in groups)
                  DropdownMenuItem<String>(value: group, child: Text(group)),
              ],
              onChanged: (value) {
                setState(() {
                  _group = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Choose a group';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // DATE OF BIRTH
            TextFormField(
              controller: _birthController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickBirthDate,
              validator: (_) {
                if (_birth == null) {
                  return 'Choose your date of birth';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // AGREEMENT CHECKBOX
            CheckboxListTile(
              title: const Text('I agree to the rules'),
              value: _agreed,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _agreed = value ?? false;
                });
              },
            ),

            const SizedBox(height: 24),

            // SIGN UP BUTTON
            FilledButton(
              onPressed: _agreed ? _signUp : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Sign up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _done ? _buildSummary() : _buildForm(),
    );
  }
}
