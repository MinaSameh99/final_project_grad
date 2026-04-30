// lib/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';
import 'package:sams/tools/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  String _selectedCode = 'st';

  bool   _isLoading = false;
  String _error     = '';

  final _roles = const [
    {'label': 'Student',          'code': 'st'},
    {'label': 'Doctor / Advisor', 'code': 'do'},
    {'label': 'Admin',            'code': 'ad'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _error = ''; });

    // ✅ Capture before async
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final result = await ApiService.register(
        fullName: _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
        code:     _selectedCode,
      );

      if (!mounted) return;

      messenger.showSnackBar(SnackBar(
        content: Text(
          result['is_active'] == true
              ? 'Account created! Please log in.'
              : 'Registered! Wait for admin approval, then log in.',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ));

      navigator.pushReplacementNamed('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('images/logo.png',
                  width: 180,
                  height: 180,
                  errorBuilder: (_, _, _) =>
                  const Icon(Icons.school, size: 180)),
            ),
            const SizedBox(height: 26),
            const Text('Create Account',
                style: TextStyle(
                    color: Color.fromARGB(255, 6, 34, 78),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const Text('Fill in your details to register',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Customtextfield(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    obscureText: false,
                    type: TextInputType.name,
                  ),
                  const SizedBox(height: 15),
                  Customtextfield(
                    label: 'Email',
                    controller: _emailCtrl,
                    obscureText: false,
                    type: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Customtextfield(
                    label: 'Password (min 8 characters)',
                    controller: _passCtrl,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // ✅ initialValue instead of deprecated value:
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCode,
                    decoration: InputDecoration(
                      labelText: 'I am a...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: const Color.fromARGB(
                          255, 238, 236, 236),
                    ),
                    items: _roles
                        .map((r) => DropdownMenuItem(
                      value: r['code']!,
                      child: Text(r['label']!),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCode = v ?? 'st'),
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error,
                    style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Already have an account? LogIn',
                    style: TextStyle(
                        color: Color.fromARGB(255, 6, 34, 78),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color.fromARGB(255, 6, 34, 78),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _signup,
                  child: const Text('Sign Up',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}