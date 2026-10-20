import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account created')));
      setState(() => _done = true);
    }
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _passwordLength = 0;
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthText.text = _formatDate(picked);
    });
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  void _hideKeyboard(PointerDownEvent _) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );

  Widget _buildSummary() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SummaryCard(
          name: _name.text,
          email: _email.text,
          group: _group ?? '',
          birth: _birthText.text,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: _hideKeyboard,
            validator: (v) =>
                (v ?? '').trim().length < 2 ? 'Name is too short' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: _hideKeyboard,
            validator: (v) {
              final email = (v ?? '').trim();
              final at = email.indexOf('@');
              if (at < 1 || !email.substring(at).contains('.')) {
                return 'Email looks wrong';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onTapOutside: _hideKeyboard,
            onChanged: (v) => setState(() => _passwordLength = v.length),
            validator: (v) =>
                (v ?? '').length < 8 ? 'Password is too short' : null,
          ),
          Text('$_passwordLength of 8'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signUp(),
            onTapOutside: _hideKeyboard,
            validator: (v) =>
                v != _password.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (g) => setState(() => _group = g),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthText,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickBirth,
            validator: (_) => _birth == null ? 'Pick a date' : null,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('I agree to the rules'),
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _signUp : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}
