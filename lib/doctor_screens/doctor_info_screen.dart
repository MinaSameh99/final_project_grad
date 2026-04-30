// lib/doctor_screens/doctor_info_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/services/api.dart';
import 'package:sams/provider/doctor_provider.dart';

class DoctorInfoScreen extends StatefulWidget {
  const DoctorInfoScreen({super.key});

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  String? _selectedDepartment;
  bool    _isLoading = false;
  String  _error     = '';

  static const _departments = [
    'MIS',
    'Marketing',
    'Accounting',
    'HR',
    'Bank Management',
    'Finance',
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null) {
      setState(() => _error = 'Please select your department');
      return;
    }

    setState(() {
      _isLoading = true;
      _error     = '';
    });

    // Capture BEFORE any await
    final docProv   = context.read<DoctorProvider>();
    final navigator = Navigator.of(context);

    try {
      await ApiService.completeAdvisorProfile(
        phone:      _phoneCtrl.text.trim(),
        department: _selectedDepartment!,
      );

      // Reload so DoctorProvider reflects new phone + department
      await docProv.loadAdvisorProfile();

      if (!mounted) return;
      navigator.pushReplacementNamed('/dochome');
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
        padding:
        const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ─────────────────────────────────────────────────
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size:  64,
                      color: Color.fromARGB(255, 6, 34, 78),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Complete Your Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:      Color.fromARGB(255, 6, 34, 78),
                          fontSize:   26,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We need a few details before you get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Phone ─────────────────────────────────────────────────
              _label('Phone Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller:   _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:   _deco('e.g. 01xxxxxxxxx'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone is required';
                  if (v.length < 10)          return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Department ────────────────────────────────────────────
              _label('Department'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                hint: const Text('Select your department'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled:    true,
                  fillColor: const Color(0xFFF5F7FB),
                ),
                items: _departments
                    .map((d) =>
                    DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged:  (v) => setState(() => _selectedDepartment = v),
                validator:  (v) => v == null ? 'Please select a department' : null,
              ),
              const SizedBox(height: 16),

              // ── Error ─────────────────────────────────────────────────
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // ── Loader ────────────────────────────────────────────────
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child:   CircularProgressIndicator(),
                  ),
                ),

              const SizedBox(height: 12),

              // ── Submit ────────────────────────────────────────────────
              SizedBox(
                width:  double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: const Text(
                    'Save & Continue',
                    style: TextStyle(
                        color:      Colors.white,
                        fontSize:   18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
        color:      Color.fromARGB(255, 19, 53, 105),
        fontSize:   16,
        fontWeight: FontWeight.w700),
  );

  InputDecoration _deco(String hint) => InputDecoration(
    hintText:  hint,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12)),
    filled:    true,
    fillColor: const Color(0xFFF5F7FB),
  );
}