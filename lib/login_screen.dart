// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/services/api.dart';
import 'package:sams/provider/admin_provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/tools/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool   _isLoading = false;
  String _error     = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error     = '';
    });

    // Capture everything BEFORE any await
    final navigator = Navigator.of(context);
    final userProv  = context.read<UserProvider>();
    final docProv   = context.read<DoctorProvider>();
    final adminProv = context.read<AdminProvider>();

    try {
      // 1. Login
      final result = await ApiService.login(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      final token  = result['access_token'] as String;
      final role   = result['role']         as String;
      final userId = result['user_id']      as int;

      // 2. Save JWT
      await ApiService.saveSession(
          token: token, role: role, userId: userId);

      // 3. Route based on role + profile completeness
      if (role == 'student') {
        await userProv.setLoginUser(_emailCtrl.text.trim());
        if (!mounted) return;
        navigator.pushReplacementNamed(
          userProv.profileComplete ? '/home' : '/studentinfo',
        );
      } else if (role == 'advisor') {
        await docProv.setLoginDoctor(_emailCtrl.text.trim());
        if (!mounted) return;
        // First login → no phone/department → go to setup screen
        navigator.pushReplacementNamed(
          docProv.profileComplete ? '/dochome' : '/docinfo',
        );
      } else if (role == 'admin') {
        await adminProv.setLoginAdmin(
          adminName:   result['full_name']?.toString() ?? 'Admin',
          adminEmail:  _emailCtrl.text.trim(),
          adminUserId: userId,
        );
        if (!mounted) return;
        navigator.pushReplacementNamed('/adminhome');
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'images/logo.png',
                width: 180,
                height: 180,
                errorBuilder: (_, _, _) =>
                const Icon(Icons.school, size: 180),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Welcome Back',
              style: TextStyle(
                  color: Color.fromARGB(255, 6, 34, 78),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'Log in to your account',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Customtextfield(
                    label:       'Email',
                    controller:  _emailCtrl,
                    obscureText: false,
                    type:        TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Customtextfield(
                    label:       'Password',
                    controller:  _passCtrl,
                    obscureText: true,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password is required'
                        : null,
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                      color: Color.fromARGB(255, 6, 34, 78),
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: SizedBox(
                width:  200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:   22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}