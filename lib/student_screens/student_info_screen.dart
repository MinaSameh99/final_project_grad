// lib/student_screens/student_info_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/services/api.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _uniIdCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();

  String? _selectedYear;
  String? _selectedDepartment;

  bool   _isLoading = false;
  String _error     = '';

  final _years = ['1', '2', '3', '4'];
  final _departments = [
    'Marketing', 'Accounting', 'Human Resources',
    'MIS', 'Finance', 'Bank Management',
  ];

  @override
  void dispose() {
    _uniIdCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null || _selectedYear == null) {
      setState(() => _error = 'Please select year and department');
      return;
    }

    setState(() { _isLoading = true; _error = ''; });

    // ✅ Capture provider and navigator BEFORE the awaits
    final userProvider = context.read<UserProvider>();
    final navigator    = Navigator.of(context);

    try {
      await ApiService.completeStudentProfile(
        uniId:      _uniIdCtrl.text.trim(),
        department: _selectedDepartment!,
        level:      int.parse(_selectedYear!),
        phone:      _phoneCtrl.text.trim(),
      );

      await userProvider.loadStudentProfile();

      if (!mounted) return;
      navigator.pushReplacementNamed('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Complete Your Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 6, 34, 78),
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),

              _label('University ID'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _uniIdCtrl,
                decoration: _inputDec('e.g. 2024001'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              _label('Phone Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDec('01xxxxxxxxx'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              _label('Year (Level)'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedYear,
                hint: const Text('Select year'),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB)),
                items: _years
                    .map((y) => DropdownMenuItem(
                    value: y, child: Text('Year $y')))
                    .toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              _label('Department'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                hint: const Text('Select department'),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB)),
                items: _departments
                    .map((d) =>
                    DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedDepartment = v),
                validator: (v) => v == null ? 'Required' : null,
              ),

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error,
                      style: const TextStyle(color: Colors.red)),
                ),
              if (_isLoading)
                const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator())),

              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: const Text('Confirm',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Color.fromARGB(255, 19, 53, 105),
          fontSize: 18,
          fontWeight: FontWeight.w700));

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: const Color(0xFFF5F7FB),
  );
}